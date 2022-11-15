<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <%--自动补全插件--%>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
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

            //设置“创建联系人”中“下次联系时间”最早从当天选择
            selectDateAfterToday("create-nextContactTime")
            selectDateAfterToday("create-expectedClosingDate")
            //input中type为date的格式，只能选择今天之后的日期（方法）
            function selectDateAfterToday(dateSelector) {
                var date = new Date()
                var year = date.getFullYear()
                var month = date.getMonth() + 1
                if(month < 10){
                    month = '0' + month
                }
                var day = date.getDate()
                if(day < 10){
                    day = '0' + day
                }
                var time = year + '-' + month + '-' + day
                $("#" + dateSelector).attr("min", time)
            }

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
            $("#saveCreateContactsRemarkBtn").click(function () {
                var noteContent = $("#remark").val()
                if (noteContent == null || noteContent == "") {
                    alert("备注内容不能为空!")
                    return
                }
                var contactsId = "${contacts.id}"
                $.ajax({
                    url: "workbench/contacts/saveCreateContactsRemarkNoteContent",
                    data: {
                        noteContent: noteContent,
                        contactsId: contactsId
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "0") {
                            alert(data.message)
                        } else {
                            //联系人备注添加成功
                            //清空输入框
                            $("#remark").val("")
                            //获取参数
                            var contactsRemark = data.obj
                            var id = contactsRemark.id
                            var createTime = contactsRemark.createTime
                            //刷新备注信息
                            var html = ""
                            html += "<div id=\"remarkDiv_" + id + "\" class=\"remarkDiv\" style=\"height: 60px;\">"
                            html += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
                            html += "<div style=\"position: relative; top: -40px; left: 40px;\" >"
                            html += "<h5>" + noteContent + "</h5>"
                            html += "<font color=\"gray\">联系人</font> <font color=\"gray\">-</font> <b>${contacts.fullName}${contacts.appellation}-${contacts.customerId}</b> <small style=\"color: gray;\"> " + createTime + " 由“${sessionScope.sessionUser.name}“发表</small>"
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
                        url: "workbench/contacts/deleteContactsRemark",
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
                    url: "workbench/contacts/saveEditContactsRemarkNoteContent",
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

            //给所有交易“删除”链接绑定单击事件
            $("#transactionList").on("click","a[name='deleteTransaction']",function () {
                var tranId = $(this).attr("tranId")
                $("#deleteTranId").val(tranId)
                //打开删除交易模态窗口
                $("#removeTransactionModal").modal("show")
            })

            //给删除交易模态窗口“删除”按钮绑定单击事件
            $("#deleteTranBtn").click(function () {
                //获取交易id
                var tranId = $("#deleteTranId").val()
                $.ajax({
                    url:"workbench/contacts/deleteTransaction",
                    data:{
                        tranId:tranId
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if (data.code == "1") {
                            //移除交易
                            $("#tran_" + tranId).remove()
                        }
                        //关闭模态窗口
                        $("#removeTransactionModal").modal("hide")
                        alert(data.message)
                    }
                })
            })

            //给“关联市场活动”按钮绑定单击事件
            $("#openCreateContactsActivityRelationBtn").click(function () {
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
                var activityListTr = $("#activityListContacts").children("tr")
                //遍历子元素获取“activityId”中值对ids拼接
                for (let i = 0; i < activityListTr.length; i++) {
                    ids += "ids=" + activityListTr.eq(i).attr("id") + "&"
                }
                ids = ids.substring(0, ids.length - 1)
                var name = this.value
                //拼接ajax发送的数据
                var ajaxData = "name=" + name + "&" + ids
                //拦截名称输入值为空
                if (name == null || name == "") {
                    return
                }
                $.ajax({
                    url: "workbench/contacts/queryActivityWithoutRelation",
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
            $("#saveCreateContactsActivityRelationBtn").click(function () {
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
                var contactsId = "${contacts.id}"
                var ajaxData = "contactsId=" + contactsId + "&" + activityIds
                $.ajax({
                    url: "workbench/contacts/addCreateContactsActivityRelation",
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
                                html += "<td><a href=\"workbench/activity/queryActivityDetail.do?id="+ id +"\" style=\"text-decoration: none;\">"+ name +"</a></td>"
                                html += "<td>" + startDate + "</td>"
                                html += "<td>" + endDate + "</td>"
                                html += "<td>" + owner + "</td>"
                                html += "<td><a href=\"javascript:void(0);\" style=\"text-decoration: none;\" name=\"cancelRelationship\" activityId=\"" + id + "\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>"
                                html += "</tr>"
                            }
                            $("#activityListContacts").append(html)
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
            $("#activityListContacts").on("click", "a[name='cancelRelationship']", function () {
                if (window.confirm("确认是否解除关联？")) {
                    var activityId = $(this).attr("activityId")
                    var contactsId = "${contacts.id}"
                    $.ajax({
                        url: "workbench/contacts/cancelContactsAndActivityRelationship",
                        data: {
                            activityId: activityId,
                            contactsId: contactsId
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
            //初始化创建交易模态窗口中表单数据
            /*-----------------------------------------------------------------------------------*/
            //给创建交易“阶段”绑定发生改变事件
            $("#create-transactionStage").change(function () {
                var stage = $("#create-transactionStage option:selected").text()
                if(stage == null || stage == "") {
                    $("#create-possibility").val("")
                    return
                }
                $.ajax({
                    url:"workbench/transaction/getPossibility",
                    data:{
                        stage:stage
                    },
                    type:"post",
                    dataType:"text",
                    success:function (data) {
                        $("#create-possibility").val(data)
                    }
                })
            })



            //给创建交易“关联市场活动”按钮绑定单击事件
            $("#openCreateActivityRelationBtn").click(function () {
                //清空“查询市场活动”输入框、列表
                $("#activityList").html("")
                $("#queryActivityByLike").val("")
                //打开“关联市场活动”模态窗口
                $("#findMarketActivity").modal("show")
            })

            //给“模糊查询市场活动”文本框绑定键起事件
            $("#queryActivityByLike").keyup(function () {
                var name = this.value
                //拦截输入值为空
                if (name == null || name == "") {
                    $("#activityList").html("")
                    return
                }
                $.ajax({
                    url: "workbench/transaction/queryActivity",
                    data: {
                        name: name
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var html = ""
                        for (let i = 0; i < data.length; i++) {
                            var activity = data[i]
                            var id = activity.id
                            var name = activity.name
                            var startDate = activity.startDate == null || activity.startDate == "" ? "？":activity.startDate
                            var endDate = activity.endDate == null || activity.endDate == "" ? "？":activity.endDate
                            var owner = activity.owner
                            html += "<tr>"
                            html += "<td><input type=\"radio\" name=\"activity\" activityId=\"" + id + "\" activityName=\"" + name + "\"/></td>"
                            html += "<td>" + name + "</td>"
                            html += "<td>" + startDate + "</td>"
                            html += "<td>" + endDate + "</td>"
                            html += "<td>" + owner + "</td>"
                            html += "</tr>"
                        }
                        $("#activityList").html(html)
                    }
                })
            })

            //给所有市场活动单选框绑定单击事件
            $("#activityList").on("click", "input[name='activity']", function () {
                var id = $(this).attr("activityId")
                var name = $(this).attr("activityName")
                //将市场活动id和name存入“创建交易”和“修改交易”的“市场活动源”中
                $("#create-activitySrc").attr("activityId", id)
                $("#create-activitySrc").val(name)
                $("#edit-activitySrc").attr("activityId", id)
                $("#edit-activitySrc").val(name)
                //关闭查找市场活动模态窗口
                $("#findMarketActivity").modal("hide")
            })

            //给创建交易“关联联系人”按钮绑定单击事件
            $("#openCreateContactsRelationBtn").click(function () {
                //清空“查询联系人”输入框、列表
                $("#contactsList").html("")
                $("#queryContactsByLike").val("")
                //打开“关联联系人”模态窗口
                $("#findContacts").modal("show")
            })

            //给“模糊查询联系人”文本框绑定键起事件
            $("#queryContactsByLike").keyup(function () {
                var fullName = this.value
                //拦截输入值为空
                if (fullName == null || fullName == "") {
                    $("#contactsList").html("")
                    return
                }
                $.ajax({
                    url: "workbench/transaction/queryContacts",
                    data: {
                        fullName: fullName
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var html = ""
                        for (let i = 0; i < data.length; i++) {
                            var contacts = data[i]
                            var id = contacts.id
                            var fullName = contacts.fullName
                            var email = contacts.email == null || contacts.email == "" ?"未知":contacts.email
                            var mphone = contacts.mphone == null || contacts.mphone == "" ?"未知":contacts.mphone
                            html += "<tr>"
                            html += "<td><input type=\"radio\" name=\"contacts\" contactsId=\"" + id + "\" contactsName=\"" + fullName + "\"/></td>"
                            html += "<td>" + fullName + "</td>"
                            html += "<td>" + email + "</td>"
                            html += "<td>" + mphone + "</td>"
                            html += "</tr>"
                        }
                        $("#contactsList").html(html)
                    }
                })
            })

            //给所有联系人单选框绑定单击事件
            $("#contactsList").on("click", "input[name='contacts']", function () {
                var id = $(this).attr("contactsId")
                var name = $(this).attr("contactsName")
                //将市场活动id和name存入“创建交易”和“修改交易”的“市场活动源”中
                $("#create-contactsName").attr("contactsId", id)
                $("#create-contactsName").val(name)
                $("#edit-contactsName").attr("contactsId", id)
                $("#edit-contactsName").val(name)
                //关闭查找市场活动模态窗口
                $("#findContacts").modal("hide")
            })
            /*-----------------------------------------------------------------------------------*/
            //给创建交易模态窗口“保存”按钮添加单击事件
            $("#saveCreateTranBtn").click(function () {
                var owner = $("#create-transactionOwner").val()
                var money = $.trim($("#create-amountOfMoney").val())
                var name = $.trim($("#create-transactionName").val())
                var expectedDate = $("#create-expectedClosingDate").val()
                var customerId = $.trim($("#create-accountName").val())
                var stage = $("#create-transactionStage").val()
                var type = $("#create-transactionType").val()
                var source = $("#create-clueSource").val()
                var activityId = $("#create-activitySrc").attr("activityId")
                var contactsId = $("#create-contactsName").attr("contactsId")
                var description = $("#create-describe").val()
                var contactSummary = $("#create-contactSummary").val()
                var nextContactTime = $("#create-nextContactTime").val()
                //拦截非法输入
                if (money != "") {
                    var regExp = /^(([1-9]\d*)|0)$/
                    if (!regExp.test(money)) {
                        alert("金额只能为非负整数!")
                        return
                    }
                }
                if (name == null || name == "") {
                    alert("名称不能为空！")
                    return
                }
                if (expectedDate == null || expectedDate == "") {
                    alert("预计成交日期不能为空！")
                    return
                }
                if (customerId == null || customerId == "") {
                    alert("客户名称不能为空！")
                    return
                }
                if (stage == null || stage == "") {
                    alert("阶段不能为空！")
                    return
                }
                //数据无误，发送ajax请求
                $.ajax({
                    url: "workbench/contacts/saveCreateTransaction",
                    data: {
                        owner: owner,
                        money: money,
                        name: name,
                        expectedDate: expectedDate,
                        customerId: customerId,
                        stage: stage,
                        type: type,
                        source: source,
                        activityId: activityId,
                        contactsId: contactsId,
                        description: description,
                        contactSummary: contactSummary,
                        nextContactTime: nextContactTime
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            //获取返回信息
                            var tran = data.obj
                            var id = tran.id
                            var name = tran.name
                            var money = tran.money == null || tran.money == "" ? "待定":tran.money
                            var stage = tran.stage
                            var expectedDate = tran.expectedDate
                            var type = tran.type == null || tran.type == "" ? "待定":tran.type
                            var possibility = tran.possibility
                            //保存成功，刷新交易列表
                            var html = ""
                            html += "<tr id=\"tran_" + id + "\">"
                            html += "<td><a href=\"workbench/transaction/queryTransactionForDetail.do?tranId="+ id +"\" style=\"text-decoration: none;\">" + name + "</a></td>"
                            html += "<td>" + money + "￥</td>"
                            html += "<td>" + stage + "</td>"
                            html += "<td>" + possibility + "</td>"
                            html += "<td>" + expectedDate + "</td>"
                            html += "<td>" + type + "</td>"
                            html += "<td><a href=\"javascript:void(0);\" style=\"text-decoration: none;\" name=\"deleteTransaction\" tranId=\"" + id + "\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>"
                            html += "</tr>"
                            $("#transactionList").append(html)
                            alert(data.message)
                            //隐藏模态窗口
                            $("#createTranModal").modal("hide")
                            //重置创建表单
                            $("#createTransactionForm").get(0).reset()
                        } else {
                            //保存失败
                            alert(data.message)
                        }
                    }
                })
            })
        })

    </script>

</head>
<body>
<!-- 创建交易的模态窗口 -->
<div class="modal fade" id="createTranModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createTranModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="createModalLabel">创建交易</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" style="position: relative; top: 5px;"
                      id="createTransactionForm">
                    <div class="form-group">
                        <label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-transactionOwner">
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-amountOfMoney">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-transactionName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-transactionName">
                        </div>
                        <label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="create-expectedClosingDate">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-accountName" class="col-sm-2 control-label">客户名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-accountName" value="${contacts.customerId}" readonly>
                        </div>
                        <label for="create-transactionStage" class="col-sm-2 control-label">阶段<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-transactionStage">
                                <option></option>
                                <c:forEach items="${stageList}" var="stage">
                                    <option value="${stage.id}">${stage.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-transactionType" class="col-sm-2 control-label">类型</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-transactionType">
                                <option></option>
                                <c:forEach items="${typeList}" var="type">
                                    <option value="${type.id}">${type.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-possibility" class="col-sm-2 control-label">可能性</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-possibility" placeholder="请选择“阶段”" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueSource">
                                <option></option>
                                <c:forEach items="${sourceList}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a
                                href="javascript:void(0);" id="openCreateActivityRelationBtn"><span
                                class="glyphicon glyphicon-search"></span></a></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-activitySrc" activityId=""
                                   placeholder="点击“放大镜”搜索" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a
                                href="javascript:void(0);" id="openCreateContactsRelationBtn"><span style="font-size: 15px; color: red;">*</span></a></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsName" contactsId="${contacts.id}" value="${contacts.fullName}" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 70%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                        <div class="col-sm-10" style="width: 70%;">
                            <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="create-nextContactTime">
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveCreateTranBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询"
                                   id="queryActivityByLike">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable3" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="activityList"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询"
                                   id="queryContactsByLike">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody id="contactsList"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

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
                <h4 class="modal-title" id="remarkModalLabel">修改备注</h4>
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

<!-- 删除交易的模态窗口 -->
<div class="modal fade" id="removeTransactionModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">删除交易</h4>
            </div>
            <div class="modal-body">
                <p>您确定要删除该交易吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <input type="hidden" id="deleteTranId">
                <button type="button" class="btn btn-danger" id="deleteTranBtn">删除</button>
            </div>
        </div>
    </div>
</div>

<!-- 解除联系人和市场活动关联的模态窗口 -->
<div class="modal fade" id="unbundActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">解除关联</h4>
            </div>
            <div class="modal-body">
                <p>您确定要解除该关联关系吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" data-dismiss="modal">解除</button>
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
                <button type="button" class="btn btn-primary" id="saveCreateContactsActivityRelationBtn">关联</button>
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
        <h3>${contacts.fullName}${contacts.appellation} <small>
            <c:if test="${empty contacts.customerId}"></c:if>
            <c:if test="${not empty contacts.customerId}">
                - ${contacts.customerId}
            </c:if>
        </small></h3>
    </div>
</div>

<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty contacts.source}">
                    未知
                </c:if>
                <c:if test="${not empty contacts.source}">
                    ${contacts.source}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.customerId}">
                    待定
                </c:if>
                <c:if test="${not empty contacts.customerId}">
                    ${contacts.customerId}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>${contacts.fullName}${contacts.appellation}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.email}">
                    未知
                </c:if>
                <c:if test="${not empty contacts.email}">
                    ${contacts.email}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty contacts.mphone}">
                    未知
                </c:if>
                <c:if test="${not empty contacts.mphone}">
                    ${contacts.mphone}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">职位</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">未知</div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${contacts.createBy}&nbsp;&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${contacts.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.editBy}">
                    无
                </c:if>
                <c:if test="${not empty contacts.editBy}">
                    ${contacts.editBy}
                </c:if>
                &nbsp;
            </b>
            <small style="font-size: 10px; color: gray;">
                <c:if test="${not empty contacts.editTime}">
                    ${contacts.editTime}
                </c:if>
            </small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.description}">
                    无
                </c:if>
                <c:if test="${not empty contacts.description}">
                    ${contacts.description}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.contactSummary}">
                    无
                </c:if>
                <c:if test="${not empty contacts.contactSummary}">
                    ${contacts.contactSummary}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.nextContactTime}">
                    待定
                </c:if>
                <c:if test="${not empty contacts.nextContactTime}">
                    ${contacts.nextContactTime}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty contacts.address}">
                    未知
                </c:if>
                <c:if test="${not empty contacts.address}">
                    ${contacts.address}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>
<!-- 备注 -->
<div id="remarkDivList" style="position: relative; top: 20px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${contactsRemarkList}" var="remark">
        <div id="remarkDiv_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">联系人</font> <font color="gray">-</font> <b>${contacts.fullName}${contacts.appellation}-${contacts.customerId}</b>
                <small
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
                <button type="button" class="btn btn-primary" id="saveCreateContactsRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 交易 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>交易</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>金额</td>
                    <td>阶段</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>类型</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="transactionList">
                <c:forEach items="${transactionList}" var="tran">
                    <tr id="tran_${tran.id}">
                        <td><a href="workbench/transaction/queryTransactionForDetail.do?tranId=${tran.id}"
                               style="text-decoration: none;">${tran.name}</a></td>
                        <td>
                            <c:if test="${empty tran.money}">
                                未知
                            </c:if>
                            <c:if test="${not empty tran.money}">
                                ${tran.money}￥
                            </c:if>
                        </td>
                        <td>${tran.stage}</td>
                        <td>${tran.possibility}</td>
                        <td>
                            <c:if test="${empty tran.expectedDate}">
                                待定
                            </c:if>
                            <c:if test="${not empty tran.expectedDate}">
                                ${tran.expectedDate}
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${empty tran.type}">
                                待定
                            </c:if>
                            <c:if test="${not empty tran.type}">
                                ${tran.type}
                            </c:if>

                        </td>
                        <td><a href="javascript:void(0);" name="deleteTransaction" tranId="${tran.id}" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <div>
            <a a href="javascript:void(0);" data-toggle="modal" data-target="#createTranModal" style="text-decoration: none;"><span
                    class="glyphicon glyphicon-plus"></span>新建交易</a>
        </div>
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
                <tbody id="activityListContacts">
                <c:forEach items="${activityList}" var="activity">
                    <tr id="${activity.id}">
                        <td><a href="workbench/activity/queryActivityDetail.do?id=${activity.id}"
                               style="text-decoration: none;">${activity.name}</a></td>
                        <td>${activity.startDate}</td>
                        <td>${activity.endDate}</td>
                        <td>${activity.owner}</td>
                        <td><a href="javascript:void(0);" style="text-decoration: none;" name="cancelRelationship"
                               activityId="${activity.id}"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <div>
            <a href="javascript:void(0);" id="openCreateContactsActivityRelationBtn"
               style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>


<div style="height: 200px;"></div>
</body>
</html>