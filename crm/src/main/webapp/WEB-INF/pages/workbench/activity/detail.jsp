<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px")
                    //显示
                    $("#cancelAndSaveBtn").show("2000")
                    cancelAndSaveBtnDefault = false
                }
            })

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide()
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px")
                cancelAndSaveBtnDefault = true
            })

            $("#remarkDivList").on("mouseover", ".remarkDiv", function () {
                $(this).children("div").children("div").show()
            })

            $("#remarkDivList").on("mouseout", ".remarkDiv", function () {
                $(this).children("div").children("div").hide()
            })

            $("#remarkDivList").on("mouseover", ".myHref", function () {
                $(this).children("span").css("color", "red")
            })

            $("#remarkDivList").on("mouseout", ".myHref", function () {
                $(this).children("span").css("color", "#E6E6E6")
            })

            //给“保存”按钮绑定单击事件
            $("#saveCreateActivityRemarkBtn").click(function () {
                var noteContent = $("#remark").val()
                if (noteContent == null || noteContent == "") {
                    alert("备注内容不能为空!")
                    return
                }
                var activityId = "${activity.id}"
                $.ajax({
                    url: "workbench/activity/saveCreateActivityRemark",
                    data: {
                        noteContent: noteContent,
                        activityId: activityId
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "0") {
                            alert(data.message)
                        } else {
                            //市场活动备注添加成功
                            //清空输入框
                            $("#remark").val("")
                            //获取参数
                            var activityRemark = data.obj
                            var id = activityRemark.id
                            var createTime = activityRemark.createTime
                            //刷新备注信息
                            var html = ""
                            html += "<div id=\"remarkDiv_" + id + "\" class=\"remarkDiv\" style=\"height: 60px;\">"
                            html += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
                            html += "<div style=\"position: relative; top: -40px; left: 40px;\" >"
                            html += "<h5>" + noteContent + "</h5>"
                            html += "<font color=\"gray\">市场活动</font> <font color=\"gray\">-</font> <b>${activity.name}</b> <small style=\"color: gray;\"> " + createTime + " 由“${sessionScope.sessionUser.name}“发表</small>"
                            html += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">"
                            html += "<a class=\"myHref\" name=\"editRemark\" remarkId=\"" + id + "\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>"
                            html += "&nbsp;&nbsp;&nbsp;&nbsp;"
                            html += "<a class=\"myHref\" name=\"deleteRemark\" remarkId=\"" + id + "\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>"
                            html += "</div>"
                            html += "</div>"
                            html += "</div>"
                            $("#remarkDiv").before(html)
                        }
                    }
                })
            })

            //给所有市场活动备注“删除”按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='deleteRemark']", function () {
                if (window.confirm("确认是否删除？")) {
                    //获取参数
                    var remarkId = $(this).attr("remarkId")
                    $.ajax({
                        url: "workbench/activity/deleteActivityRemark",
                        data: {
                            id: remarkId
                        },
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功，刷新备注列表
                                $("#remarkDiv_" + remarkId).remove()
                            } else {
                                //删除失败，提示错误信息
                                alert(data.message)
                            }
                        }
                    })
                }
            })

            //给所有市场活动备注”修改“按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='editRemark']", function () {
                var remarkId = $(this).attr("remarkId")
                $("#editId").val(remarkId)
                //打开修改市场活动备注模态窗口
                $("#editRemarkModal").modal("show")
                var defaultNoteContent = $("#remarkDiv_" + remarkId + " h5").text()
                //设置默认文本内容
                $("#noteContent").val(defaultNoteContent)
            })

            //给“更新”市场活动备注按钮绑定单击事件
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#editId").val()
                var noteContent = $("#noteContent").val()
                //拦截空的修改内容
                if (noteContent == null || noteContent == "") {
                    alert("输入内容不能为空！")
                    return
                }
                $.ajax({
                    url: "workbench/activity/editActivityRemarkNoteContent",
                    data: {
                        id: remarkId,
                        noteContent: noteContent
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            var editTime = data.obj.editTime
                            //修改显示内容
                            $("#remarkDiv_" + remarkId + " h5").text(noteContent)
                            $("#remarkDiv_" + remarkId + " small").text(editTime + " 由“${sessionScope.sessionUser.name}”修改")
                            //关闭修改市场活动备注模态窗口
                            $("#editRemarkModal").modal("hide")
                        }
                        alert(data.message)
                    }
                })
            })
        })

    </script>

</head>
<body>

<!-- 修改市场活动备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
    <%-- 备注的id --%>
    <input type="hidden" id="remarkId">
    <div class="modal-dialog" role="document" style="width: 40%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改备注</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <input type="hidden" id="editId">
                    <div class="form-group">
                        <label for="noteContent" class="col-sm-2 control-label">内容</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="noteContent"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>市场活动-${activity.name}
            <small>
                <c:if test="${empty activity.startDate}">
                    ?
                </c:if>
                <c:if test="${not empty activity.startDate}">
                    ${activity.startDate}
                </c:if>
                <c:if test="${not empty activity.startDate or not empty activity.endDate}">
                    ~
                </c:if>
                <c:if test="${empty activity.endDate}">
                    ?
                </c:if>
                <c:if test="${not empty activity.endDate}">
                    ${activity.endDate}
                </c:if>
            </small>
        </h3>
    </div>
</div>

<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>

    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">开始日期</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty activity.startDate}">
                    待定
                </c:if>
                <c:if test="${not empty activity.startDate}">
                    ${activity.startDate}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty activity.endDate}">
                    待定
                </c:if>
                <c:if test="${not empty activity.endDate}">
                    ${activity.endDate}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">成本</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty activity.cost}">
                    待定
                </c:if>
                <c:if test="${not empty activity.cost}">
                    ${activity.cost}元
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${activity.createBy}</b>&nbsp;&nbsp;<small
                style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty activity.editBy}">
                    无
                </c:if>
                <c:if test="${not empty activity.editBy}">
                    ${activity.editBy}
                </c:if>
            </b>&nbsp;<small style="font-size: 10px; color: gray;">${activity.editTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty activity.description}">
                    无
                </c:if>
                <c:if test="${not empty activity.description}">
                    ${activity.description}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkDivList" style="position: relative; top: 30px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${activityRemarks}" var="remark">
        <div id="remarkDiv_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small
                    style="color: gray;"> ${remark.editFlag=="1" ? remark.editTime : remark.createTime}
                由“${remark.editFlag=="1" ? remark.editBy : remark.createBy}“${remark.editFlag=="1" ? "修改" : "发表"}</small>
                <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                    <a class="myHref" name="editRemark" remarkId="${remark.id}" href="javascript:void(0);"><span
                            class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <a class="myHref" name="deleteRemark" remarkId="${remark.id}" href="javascript:void(0);"><span
                            class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
                </div>
            </div>
        </div>
    </c:forEach>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveCreateActivityRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>
<div style="height: 200px;"></div>
</body>
</html>