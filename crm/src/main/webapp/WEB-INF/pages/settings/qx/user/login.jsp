<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript">
        $(function () {
            //十天内免登录直接跳转到主界面
            var loginAct = $("#loginAct").val()
            if (loginAct != "") {
                loginCheck()//登录验证
            }

            //给“登录”按钮绑定单击事件
            $("#loginBtn").click(function () {
                loginCheck()
            })

            //给浏览器窗口绑定键盘键入事件
            $(window).keydown(function (event) {
                //键入“Enter”
                if (event.keyCode == 13) {
                    $("#loginBtn").click()
                }
            })

            //登录验证（方法）
            function loginCheck() {
                var loginAct = $.trim($("#loginAct").val())
                var loginPwd = $("#loginPwd").val()
                var isRemPwd = $("#isRemPwd").prop("checked")
                //账号密码是否为空
                if (loginAct == "" && loginPwd == "") {
                    $("#msg").html("<font color='red'>用户名、密码不能为空</font>")
                    return
                }
                if (loginAct == "") {
                    $("#msg").html("<font color='red'>用户名不能为空</font>")
                    return
                }
                if (loginPwd == "") {
                    $("#msg").html("<font color='red'>密码不能为空</font>")
                    return
                }
                $.ajax({
                    beforeSend: function () {
                        $("#msg").html("<font color='green'>正在验证....</font>")
                        return true
                    },
                    url: 'settings/qx/user/login',
                    data: {
                        loginAct: loginAct,
                        loginPwd: loginPwd,
                        isRemPwd: isRemPwd,
                    },
                    type: 'post',
                    dataType: 'json',
                    success: function (data) {
                        var code = data.code
                        var message = data.message
                        if (code == "1") {
                            //登录成功，跳转工作台页面
                            window.location.href = 'workbench/index.do'
                            //清空msg
                            $("#msg").text("")
                        } else {
                            //登录失败，输出错误信息
                            $("#msg").html("<font color='red'>" + message + "</font>")
                        }
                    }
                })
            }
        })
    </script>
</head>
<body>
<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
    <img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
</div>
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        CRM &nbsp;<span style="font-size: 12px;">&copy;2022&nbsp;yibiyihua</span></div>
</div>

<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
    <div style="position: absolute; top: 0px; right: 60px;">
        <div class="page-header">
            <h1>登录</h1>
        </div>
        <div class="form-group form-group-lg">
            <div style="width: 350px;">
                <input class="form-control" type="text" id="loginAct" value="${cookie.loginAct.value}"
                       placeholder="用户名">
            </div>
            <div style="width: 350px; position: relative;top: 20px;">
                <input class="form-control" type="password" id="loginPwd" value="${cookie.loginPwd.value}"
                       placeholder="密码">
            </div>
            <div class="checkbox" style="position: relative;top: 30px; left: 10px;">
                <label>
                    <c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
                        <input type="checkbox" id="isRemPwd"> 十天内免登录
                    </c:if>
                    <c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
                        <input type="checkbox" id="isRemPwd" checked> 十天内免登录
                    </c:if>
                </label>
                <span id="msg"></span>
            </div>
            <button id="loginBtn" class="btn btn-primary btn-lg btn-block"
                    style="width: 350px; position: relative;top: 45px;">登录
            </button>
        </div>
    </div>
</div>
</body>
</html>
