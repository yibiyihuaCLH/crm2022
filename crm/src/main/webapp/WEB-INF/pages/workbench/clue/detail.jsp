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
            $("#saveCreateClueRemarkBtn").click(function () {
                var noteContent = $("#remark").val()
                if (noteContent == null || noteContent == "") {
                    alert("备注内容不能为空!")
                    return
                }
                var clueId = "${clue.id}"
                $.ajax({
                    url: "workbench/clue/saveCreateClueRemarkNoteContent",
                    data: {
                        noteContent: noteContent,
                        clueId: clueId
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "0") {
                            alert(data.message)
                        } else {
                            //线索备注添加成功
                            //清空输入框
                            $("#remark").val("")
                            //获取参数
                            var clueRemark = data.obj
                            var id = clueRemark.id
                            var createTime = clueRemark.createTime
                            //刷新备注信息
                            var html = ""
                            html += "<div id=\"remarkDiv_" + id + "\" class=\"remarkDiv\" style=\"height: 60px;\">"
                            html += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
                            html += "<div style=\"position: relative; top: -40px; left: 40px;\" >"
                            html += "<h5>" + noteContent + "</h5>"
                            html += "<font color=\"gray\">线索</font> <font color=\"gray\">-</font> <b>${clue.fullName}${clue.appellation}-${clue.company}</b> <small style=\"color: gray;\"> " + createTime + " 由“${sessionScope.sessionUser.name}“发表</small>"
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

            //给所有备注“删除”按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='deleteRemark']", function () {
                if (window.confirm("确认是否删除？")) {
                    //获取参数
                    var remarkId = $(this).attr("remarkId")
                    $.ajax({
                        url: "workbench/clue/deleteClueRemark",
                        data: {
                            id: remarkId
                        },
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功，刷新备注列表
                                $("#remarkDiv_" + remarkId).remove()
                            }else {
                                alert(data.message)
                            }
                        }
                    })
                }
            })

            //给所有备注”修改“按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='editRemark']", function () {
                var remarkId = $(this).attr("remarkId");
                $("#editId").val(remarkId)
                //打开修改线索备注模态窗口
                $("#editRemarkModal").modal("show")
                var defaultNoteContent = $("#remarkDiv_" + remarkId + " h5").text()
                //设置默认文本内容
                $("#noteContent").val(defaultNoteContent)
            })

            //给“更新”备注按钮绑定单击事件
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#editId").val()
                var noteContent = $("#noteContent").val()
                //拦截空的修改内容
                if (noteContent == null || noteContent == "") {
                    alert("输入内容不能为空！")
                    return
                }
                $.ajax({
                    url: "workbench/clue/saveEditClueRemarkNoteContent",
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
                            //关闭修改线索备注模态窗口
                            $("#editRemarkModal").modal("hide")
                        }
                        alert(data.message)
                    }
                })
            })

            //给“关联市场活动”按钮绑定单击事件
            $("#openCreateClueActivityRelationBtn").click(function () {
                //清空“查询市场活动”输入框、列表和全选框
                $("#queryActivityTbody").html("")
                $("#queryActivity").val("")
                $("#checkAll").prop("checked", false)
                //打开“关联市场活动”模态窗口
                $("#bundModal").modal("show")
            })

            //给关联市场活动模态窗口“取消”按钮绑定单击事件
            $("#closeActivityRelation").click(function () {
                //关闭关联市场活动模态窗口
                $("#bundModal").modal("hide")
            })

            //给全选框绑定点击事件
            $("#checkAll").click(function () {
                $("#activityTable input[type='checkbox']").prop("checked", this.checked)
            })
            $("#queryActivityTbody").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#queryActivityTbody input[type='checkbox']").size() == $("#queryActivityTbody input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {
                    //如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给模糊“查询市场活动”键盘弹起绑定单击事件
            $("#queryActivity").keyup(function () {
                $("#queryActivityTbody").html("")
                var ids = ""
                //获取线索关联的市场活动列表子元素对象
                var activityListTr = $("#activityList").children("tr")
                //遍历子元素获取“activityId”中值对ids拼接
                for (let i = 0; i < activityListTr.length; i++) {
                    ids += "ids=" + activityListTr.eq(i).attr("id") + "&"
                }
                ids = ids.substring(0, ids.length - 1)
                var name = this.value
                //拼接ajax发送的数据
                var ajaxData = "name=" + name + "&" + ids
                //拦截名称输入值为空
                if (name == "") {
                    return
                }
                $.ajax({
                    url: "workbench/clue/queryActivityWithoutRelation",
                    data: ajaxData,
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var html = ""
                        for (let i = 0; i < data.length; i++) {
                            var activity = data[i]
                            var id = activity.id
                            var name = activity.name
                            var startDate = activity.startDate == "" ? "？":activity.startDate
                            var endDate = activity.endDate =="" ? "？":activity.endDate
                            var owner = activity.owner
                            html += "<tr>"
                            html += "<td><input type=\"checkbox\" value=\"" + id + "\"/></td>"
                            html += "<td>" + name + "</td>"
                            html += "<td>" + startDate + "</td>"
                            html += "<td>" + endDate + "</td>"
                            html += "<td>" + owner + "</td>"
                            html += "</tr>"
                        }
                        $("#queryActivityTbody").html(html)
                    }
                })
            })

            //给“关联”按钮绑定单击事件
            $("#saveCreateClueActivityRelationBtn").click(function () {
                //收集参数
                var checkedIds = $("#queryActivityTbody input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("至少关联一条市场活动")
                    return
                }
                //拼接data数据
                var activityIds = ""
                for (let i = 0; i < checkedIds.length; i++) {
                    activityIds += "activityIds=" + checkedIds[i].value + "&"
                }
                activityIds = activityIds.substring(0, activityIds.length - 1)
                var clueId = "${clue.id}"
                var ajaxData = "clueId=" + clueId + "&" + activityIds
                $.ajax({
                    url: "workbench/clue/addCreateClueActivityRelation",
                    data: ajaxData,
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            var html = ""
                            var activities = data.obj
                            for (let i = 0; i < activities.length; i++) {
                                var activity = activities[i]
                                var id = activity.id
                                var name = activity.name
                                var startDate = activity.startDate == "" ? "？":activity.startDate
                                var endDate = activity.endDate == "" ? "？":activity.endDate
                                var owner = activity.owner
                                html += "<tr id=\"" + id + "\">"
                                html += "<td>" + name + "</td>"
                                html += "<td>" + startDate + "</td>"
                                html += "<td>" + endDate + "</td>"
                                html += "<td>" + owner + "</td>"
                                html += "<td><a href=\"javascript:void(0);\" style=\"text-decoration: none;\" name=\"cancelRelationship\" activityId=\"" + id + "\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>"
                                html += "</tr>"
                            }
                            $("#activityList").append(html)
                            //关闭关联市场活动模态窗口
                            $("#bundModal").modal("hide")
                            alert(data.message)
                        } else {
                            $("#bundModal").modal("show")
                            alert(data.message)
                        }
                    }
                })
            })

            //给所有“解除关联”链接绑定单击事件
            $("#activityList").on("click", "a[name='cancelRelationship']", function () {
                if (window.confirm("确认是否解除关联？")) {
                    var activityId = $(this).attr("activityId")
                    var clueId = "${clue.id}"
                    $.ajax({
                        url: "workbench/clue/cancelClueAndActivityRelationship",
                        data: {
                            activityId: activityId,
                            clueId: clueId
                        },
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,删除页面上关联的市场活动
                                $("#" + activityId).remove()
                            }
                            alert(data.message)
                        }
                    })
                }
            })

            //给“转换”按钮绑定单击事件
            $("#clueConvertBtn").click(function () {
                var id = "${clue.id}"
                window.location.href = "workbench/clue/clueConvert.do?id=" + id
            })

        })


    </script>

</head>
<body>

<!-- 修改线索备注的模态窗口 -->
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

<!-- 关联市场活动的模态窗口 -->
<div class="modal fade" id="bundModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">关联市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询"
                                   id="queryActivity">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td><input type="checkbox" id="checkAll"/></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="queryActivityTbody"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="saveCreateClueActivityRelationBtn">关联</button>
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
        <h3>${clue.fullName}${clue.appellation} <small>${clue.company}</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" id="clueConvertBtn">
            <span class="glyphicon glyphicon-retweet"></span> 转换
        </button>

    </div>
</div>

<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>${clue.fullName}${clue.appellation}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.owner}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.company}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty clue.job}">
                    未知
                </c:if>
                <c:if test="${not empty clue.job}">
                    ${clue.job}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.email}">
                    未知
                </c:if>
                <c:if test="${not empty clue.email}">
                    ${clue.email}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty clue.phone}">
                    未知
                </c:if>
                <c:if test="${not empty clue.phone}">
                    ${clue.phone}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.website}">
                    未知
                </c:if>
                <c:if test="${not empty clue.website}">
                    ${clue.website}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty clue.mphone}">
                    未知
                </c:if>
                <c:if test="${not empty clue.mphone}">
                    ${clue.mphone}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">线索状态</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.state}">
                    待定
                </c:if>
                <c:if test="${not empty clue.state}">
                    ${clue.state}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty clue.source}">
                    未知
                </c:if>
                <c:if test="${not empty clue.source}">
                    ${clue.source}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.createBy}&nbsp;&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${clue.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.editBy}">
                    无
                </c:if>
                <c:if test="${not empty clue.editBy}">
                    ${clue.editBy}
                </c:if>&nbsp;
            </b>
            <small style="font-size: 10px; color: gray;">${clue.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.description}">
                    无
                </c:if>
                <c:if test="${not empty clue.description}">
                    ${clue.description}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.contactSummary}">
                    无
                </c:if>
                <c:if test="${not empty clue.contactSummary}">
                    ${clue.contactSummary}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.nextContactTime}">
                    待定
                </c:if>
                <c:if test="${not empty clue.nextContactTime}">
                    ${clue.nextContactTime}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty clue.address}">
                    未知
                </c:if>
                <c:if test="${not empty clue.address}">
                    ${clue.address}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkDivList" style="position: relative; top: 40px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${clueRemarks}" var="remark">
        <div id="remarkDiv_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">线索</font> <font color="gray">-</font>
                <b>${clue.fullName}${clue.appellation}-${clue.company}</b> <small
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
                <button type="button" class="btn btn-primary" id="saveCreateClueRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 市场活动 -->
<div>
    <div style="position: relative; top: 60px; left: 40px;">
        <div class="page-header">
            <h4>市场活动</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>所有者</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="activityList">
                <c:forEach items="${activities}" var="activity">
                    <tr id="${activity.id}">
                        <td>${activity.name}</td>
                        <td><c:if test="${empty activity.startDate}">？</c:if><c:if test="${not empty activity.startDate}">${activity.startDate}</c:if></td>
                        <td><c:if test="${empty activity.endDate}">？</c:if><c:if test="${not empty activity.endDate}">${activity.endDate}</c:if></td>
                        <td>${activity.owner}</td>
                        <td><a href="javascript:void(0);" style="text-decoration: none;" name="cancelRelationship"
                               activityId="${activity.id}"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <div>
            <a href="javascript:void(0);" style="text-decoration: none;" id="openCreateClueActivityRelationBtn"><span
                    class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>


<div style="height: 200px;"></div>
</body>
</html>