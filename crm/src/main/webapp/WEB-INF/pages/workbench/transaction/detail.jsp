<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>

    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }
    </style>

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

            //阶段提示框
            $(".mystage").popover({
                trigger: 'manual',
                placement: 'bottom',
                html: 'true',
                animation: false
            })

            $("#stageList").on("mouseenter",".mystage",function () {
                var _this = this
                $(this).popover("show")
                $(this).siblings(".popover").on("mouseleave", function () {
                    $(_this).popover('hide')
                })
            }).on("mouseleave", function () {
                var _this = this
                setTimeout(function () {
                    if (!$(".popover:hover").length) {
                        $(_this).popover("hide")
                    }
                }, 100)
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

            //给备注“保存”按钮绑定单击事件
            $("#saveCreateTranRemarkBtn").click(function () {
                var noteContent = $("#remark").val()
                if (noteContent == null || noteContent == "") {
                    alert("备注内容不能为空!")
                    return
                }
                var tranId = "${tran.id}"
                $.ajax({
                    url: "workbench/transaction/saveCreateTransactionRemark",
                    data: {
                        noteContent: noteContent,
                        tranId: tranId
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "0") {
                            alert(data.message)
                        } else {
                            //客户备注添加成功
                            //清空输入框
                            $("#remark").val("")
                            //获取参数
                            var tranRemark = data.obj
                            var id = tranRemark.id
                            var createTime = tranRemark.createTime
                            //刷新备注信息
                            var html = ""
                            html += "<div id=\"remarkDiv_" + id + "\" class=\"remarkDiv\" style=\"height: 60px;\">"
                            html += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
                            html += "<div style=\"position: relative; top: -40px; left: 40px;\" >"
                            html += "<h5>" + noteContent + "</h5>"
                            html += "<font color=\"gray\">交易</font> <font color=\"gray\">-</font> <b>${tran.name}</b> <small style=\"color: gray;\"> " + createTime + " 由“${sessionScope.sessionUser.name}“发表</small>"
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

            //给所有客户备注“删除”按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='deleteRemark']", function () {
                if (window.confirm("确认是否删除？")) {
                    //获取参数
                    var remarkId = $(this).attr("remarkId")
                    $.ajax({
                        url: "workbench/transaction/deleteTransactionRemark",
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

            //给所有客户备注”修改“按钮绑定单击事件
            $("#remarkDivList").on("click", "a[name='editRemark']", function () {
                var remarkId = $(this).attr("remarkId");
                $("#editId").val(remarkId)
                //打开修改市场活动备注模态窗口
                $("#editRemarkModal").modal("show")
                var defaultNoteContent = $("#remarkDiv_" + remarkId + " h5").text()
                //设置默认文本内容
                $("#noteContent").val(defaultNoteContent)
            })

            //给“更新”客户备注按钮绑定单击事件
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#editId").val()
                var noteContent = $("#noteContent").val()
                //拦截空的修改内容
                if (noteContent == null || noteContent == "") {
                    alert("输入内容不能为空！")
                    return
                }
                $.ajax({
                    url: "workbench/transaction/saveEditTransactionRemark",
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

            //给所有“阶段”按钮绑定单击事件
            $("#stageList").on("click","span[name='stage']",function () {
                var stageName = $(this).attr("data-content")
                if (stageName == $("#stage").text()) {
                    alert("请选择其他阶段!")
                    return
                }
                if ($("#stage").text() == "成交") {
                    alert("交易已成交！")
                    return
                }
                if (window.confirm("确认更新状态？")) {
                    //获取参数
                    var stage = $(this).attr("stageId")
                    var money = "${tran.money}"
                    var expectedDate = "${tran.expectedDate}"
                    var tranId = "${tran.id}"
                    $.ajax({
                        url: "workbench/transaction/saveTransactionHistory",
                        data: {
                            stage: stage,
                            money: money,
                            expectedDate: expectedDate,
                            tranId: tranId,
                            stageName: stageName
                        },
                        type: "post",
                        dataType: "json",
                        success:function (data) {
                            if (data.code == "1") {
                                var returnObj = data.obj
                                var tranEditBy = returnObj.tranEditBy
                                var tranEditTime = returnObj.tranEditTime
                                var possibility = returnObj.possibility
                                //更改详细信息
                                var detailHtml = ""
                                detailHtml += "<b>" + tranEditBy + "&nbsp;&nbsp;&nbsp;</b>"
                                detailHtml += "<small style=\"font-size: 10px; color: gray;\">" + tranEditTime + "</small></div>"
                                $("#tranEdit").html(detailHtml)
                                $("#stage").html(stageName)
                                $("#possibility").html(possibility + "%")
                                //添加历史信息
                                var money = "${tran.money}" == null || "${tran.money}" == "" ? "待定" : "${tran.money}"
                                var expectedDate = "${tran.expectedDate}"
                                var hisCreateTime = returnObj.hisCreateTime
                                var owner = returnObj.hisCreateBy
                                var historyHtml = ""
                                historyHtml += "<tr>"
                                historyHtml += "<td>" + stageName + "</td>"
                                historyHtml += "<td>" + money + "￥</td>"
                                historyHtml += "<td>" + possibility + "%</td>"
                                historyHtml += "<td>" + expectedDate + "</td>"
                                historyHtml += "<td>" + hisCreateTime + "</td>"
                                historyHtml += "<td>" + owner + "</td>"
                                historyHtml += "</tr>"
                                $("#historyList").append(historyHtml)
                                //刷新阶段图标
                                var stageList = returnObj.stageList
                                var localStage = returnObj.localStage
                                var stageHtml = ""
                                stageHtml += "阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                                for (let i = 0; i < stageList.length; i++) {
                                    var stage = stageList[i]
                                    if (localStage.orderNo == stage.orderNo) {
                                        stageHtml += "<span class=\"glyphicon glyphicon-map-marker mystage\" data-toggle=\"popover\" data-placement=\"bottom\""
                                        stageHtml += "data-content=\"" + stage.value + "\" name=\"stage\" stageId=\"" + stage.id + "\" style=\"color: #90F790;\"></span>"
                                    } else if (localStage.orderNo > stage.orderNo) {
                                        stageHtml += "<span class=\"glyphicon glyphicon-ok-circle mystage\" data-toggle=\"popover\" data-placement=\"bottom\""
                                        stageHtml += "data-content=\"" + stage.value + "\" name=\"stage\" stageId=\"" + stage.id + "\" style=\"color: #90F790;\"></span>"
                                    } else {
                                        stageHtml += "<span class=\"glyphicon glyphicon-record mystage\" data-toggle=\"popover\" data-placement=\"bottom\""
                                        stageHtml += "data-content=\"" + stage.value + "\" name=\"stage\" stageId=\"" + stage.id + "\"></span>"
                                    }
                                    stageHtml += "&nbsp;-----------&nbsp;"
                                }
                                stageHtml += "<span class=\"closingDate\">${tran.expectedDate}</span>"
                                $("#stageList").html(stageHtml)
                            }
                        }
                    })
                }
            })
        })





    </script>

</head>
<body>
<!-- 修改客户备注的模态窗口 -->
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
        <h3>
            ${tran.name}
            <small>
                <c:if test="${empty tran.money}">
                    待定
                </c:if>
                <c:if test="${not empty tran.money}">
                    ￥${tran.money}
                </c:if>
            </small>
        </h3>
    </div>

</div>

<br/>
<br/>
<br/>

<!-- 阶段状态 -->
<div id="stageList" style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <c:forEach items="${stageList}" var="stage">
        <c:if test="${localStage.orderNo == stage.orderNo}">
    <span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom"
          data-content="${stage.value}" name="stage" stageId="${stage.id}" style="color: #90F790;"></span>
            -----------
        </c:if>
        <c:if test="${localStage.orderNo > stage.orderNo}">
        <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
              data-content="${stage.value}" name="stage" stageId="${stage.id}" style="color: #90F790;"></span>
            -----------
        </c:if>
        <c:if test="${localStage.orderNo < stage.orderNo}">
            <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
                  data-content="${stage.value}" name="stage" stageId="${stage.id}"></span>
            -----------
        </c:if>
    </c:forEach>
    <span class="closingDate">${tran.expectedDate}</span>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty tran.money}">
                    待定
                </c:if>
                <c:if test="${not empty tran.money}">
                    ${tran.money}￥
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.name}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.type}">
                    待定
                </c:if>
                <c:if test="${not empty tran.type}">
                    ${tran.type}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${possibility}%</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.source}">
                    未知
                </c:if>
                <c:if test="${not empty tran.source}">
                    ${tran.source}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty tran.activityId}">
                    未知
                </c:if>
                <c:if test="${not empty tran.activityId}">
                    ${tran.activityId}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.customerId}">
                    待定
                </c:if>
                <c:if test="${not empty tran.customerId}">
                    ${tran.customerId}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${tran.createBy}&nbsp;&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;" id="tranEdit">
            <b>
                <c:if test="${empty tran.editBy}">
                    未知
                </c:if>
                <c:if test="${not empty tran.editBy}">
                    ${tran.editBy}
                </c:if>&nbsp;
            </b>
            <small style="font-size: 10px; color: gray;">${tran.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.description}">
                    无
                </c:if>
                <c:if test="${not empty tran.description}">
                    ${tran.description}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.contactSummary}">
                    无
                </c:if>
                <c:if test="${not empty tran.contactSummary}">
                    ${tran.contactSummary}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty tran.nextContactTime}">
                    待定
                </c:if>
                <c:if test="${not empty tran.nextContactTime}">
                    ${tran.nextContactTime}
                </c:if>
            </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkDivList" style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${tranRemarkList}" var="remark">
        <div id="remarkDiv_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">交易</font> <font color="gray">-</font> <b>${tran.name}</b> <small
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
                <button type="button" class="btn btn-primary" id="saveCreateTranRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>创建时间</td>
                    <td>创建人</td>
                </tr>
                </thead>
                <tbody id="historyList">
                <c:forEach items="${tranHistoryList}" var="history">
                    <tr>
                        <td>${history.stage}</td>
                        <td>
                            <c:if test="${empty history.money}">
                                待定
                            </c:if>
                            <c:if test="${not empty history.money}">
                                ${history.money}￥
                            </c:if>
                        </td>
                        <td>${history.possibility}%</td>
                        <td>${history.expectedDate}</td>
                        <td>${history.createTime}</td>
                        <td>${history.createBy}</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>

</body>
</html>