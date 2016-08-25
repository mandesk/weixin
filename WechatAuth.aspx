<%@ Page Language="C#" AutoEventWireup="true" Inherits="System.Web.UI.Page" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
        </div>
    </form>
</body>
</html>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string appid = "wxde5cb829d172ed53";
        string secret = "06c1700b7a4ead7dc4a51e62714feb45";
        string at = "";
        //if (HttpRuntime.Cache["at"] != null)
        //    at = HttpRuntime.Cache["at"].ToString();
        //else
        //{
            at = GetAccess_Token(appid, secret);
        //    HttpRuntime.Cache.Add("at", at, null,
        //   DateTime.Now.AddHours(2),
        //   System.Web.Caching.Cache.NoSlidingExpiration,
        //   System.Web.Caching.CacheItemPriority.NotRemovable,
        //   null);
        //}
        string code = this.Request.QueryString["code"];
        //string state = this.Request.QueryString["STATE"];
        string ares = RequestByGet("https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + appid + "&secret=" + secret + "&code=" + code + "&grant_type=authorization_code");
        string access_token = GetJsonValue(ares, "access_token");
        string refresh_token = GetJsonValue(ares, "refresh_token");
        string openid = GetJsonValue(ares, "openid");
        ares = RequestByGet("https://api.weixin.qq.com/cgi-bin/user/info?access_token=" + at + "&openid=" + openid + "&lang=zh_CN");
        //ares = RequestByGet("https://api.weixin.qq.com/sns/userinfo?access_token=" + access_token + "&openid=" + openid + "&lang=zh_CN");
        string subs = GetJsonValue(ares, "subscribe");
        if (subs == "1")
        {
            Response.Output.Write(ares);
        }
        else
            Response.Output.Write("未关注用户");
    }

    public static string GetAccess_Token(string appid, string appsecret)
    {
        string Json = RequestByGet("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" + appid + "&secret=" + appsecret);
        return GetJsonValue(Json, "access_token");
    }
    public static string GetJsonValue(string jsonStr, string key)
    {
        string result = string.Empty;
        if (!string.IsNullOrEmpty(jsonStr))
        {
            key = "\"" + key.Trim('"') + "\"";
            int index = jsonStr.IndexOf(key) + key.Length + 1;
            if (index > key.Length + 1)
            {
                //先截逗号，若是最后一个，截“｝”号，取最小值
                int end = jsonStr.IndexOf(',', index);
                if (end == -1)
                {
                    end = jsonStr.IndexOf('}', index);
                }

                result = jsonStr.Substring(index, end - index);
                result = result.Trim(new char[] { '"', ' ', '\'' }); //过滤引号或空格
            }
        }
        return result;
    }
    public static string RequestByGet(string url)
    {
        return _WebRequest("get", url, null);
    }
    private static string _WebRequest(string method, string url, string postData)
    {
        HttpWebRequest webRequest = null;
        StreamWriter requestWriter = null;
        string responseData = "";
        webRequest = System.Net.WebRequest.Create(url) as HttpWebRequest;
        webRequest.Method = method.ToString();
        webRequest.ServicePoint.Expect100Continue = false;
        if (method.ToLower() == "post")
        {
            webRequest.ContentType = "application/x-www-form-urlencoded";
            requestWriter = new StreamWriter(webRequest.GetRequestStream());
            try
            {
                requestWriter.Write(postData);
            }
            catch
            {
                throw;
            }
            finally
            {
                requestWriter.Close();
                requestWriter = null;
            }
        }
        responseData = _WebResponseGet(webRequest);
        webRequest = null;
        return responseData;
    }
    private static string _WebResponseGet(HttpWebRequest webRequest)
    {
        StreamReader responseReader = null;
        string responseData = "";
        try
        {
            responseReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            responseData = responseReader.ReadToEnd();
        }
        catch
        {
            throw;
        }
        finally
        {
            webRequest.GetResponse().GetResponseStream().Close();
            responseReader.Close();
            responseReader = null;
        }
        return responseData;
    }
</script>
