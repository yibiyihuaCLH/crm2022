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

            //设置“创建联系人”和“新建联系人”中“下次联系时间”最早从当天选择
            selectDateAfterToday("create-nextContactTime")
            selectDateAfterToday("create-expectedClosingDate")
            selectDateAfterToday("create-nextContactTimeContacts")
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

            //给“保存”按钮绑定单击事件
            $("#saveCreateCustomerRemarkBtn").click(function () {
                var noteContent = $("#remark").val()
                if (noteContent == null || noteContent == "") {
                    alert("备注内容不能为空!")
                    return
                }
                var customerId = "${customer.id}"
                $.ajax({
                    url: "workbench/customer/saveCreateCustomerRemark",
                    data: {
                        noteContent: noteContent,
                        customerId: customerId
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
                            var customerRemark = data.obj
                            var id = customerRemark.id
                            var createTime = customerRemark.createTime
                            //刷新备注信息
                            var html = ""
                            html += "<div id=\"remarkDiv_" + id + "\" class=\"remarkDiv\" style=\"height: 60px;\">"
                            html += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
                            html += "<div style=\"position: relative; top: -40px; left: 40px;\" >"
                            html += "<h5>" + noteContent + "</h5>"
                            html += "<font color=\"gray\">客户</font> <font color=\"gray\">-</font> <b>${customer.name}</b> <small style=\"color: gray;\"> " + createTime + " 由“${sessionScope.sessionUser.name}“发表</small>"
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
                        url: "workbench/customer/deleteCustomerRemark",
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
                    url: "workbench/customer/editCustomerRemarkNoteContent",
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
                    url:"workbench/customer/deleteTransaction",
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

            //给所有联系人“删除”链接绑定单击事件
            $("#customerContactsList").on("click","a[name='deleteContacts']",function () {
                if (window.confirm("确认删除联系人？")) {
                    var contactsId = $(this).attr("contactsId")
                    $.ajax({
                        url:"workbench/customer/deleteContacts",
                        data:{
                            contactsId:contactsId
                        },
                        type:"post",
                        dataType:"json",
                        success:function (data) {
                            if (data.code == "1") {
                                //移除交易
                                $("#contactsId_" + contactsId).remove()
                            }
                            //关闭模态窗口
                            $("#removeContactsModal").modal("hide")
                            alert(data.message)
                        }
                    })
                }
            })

            //给删除联系人模态窗口“删除”按钮绑定单击事件
            $("#deleteContactsBtn").click(function () {
                //获取交易id
                var contactsId = $("#deleteContactsId").val()

            })

            //给“新建联系人”链接绑定单击事件
            $("#createContactsBtn").click(function () {
                //设置所有者默认为当前用户
                $("#create-contactsOwner  option[value='${sessionScope.sessionUser.id}'] ").attr("selected",true)
                //设置客户名称为当前客户
                $("#create-customerName").val("${customer.name}")
                //弹出创建客户的模态窗口
                $("#createContactsModal").modal("show")
            })

            //给创建联系人模态窗口“保存”按钮添加单击事件
            $("#saveCreateContactsBtn").click(function () {
                var owner = $("#create-contactsOwner").val()
                var source = $("#create-clueSourceContacts").val()
                var customerId = $.trim($("#create-customerName").val())
                var fullName = $.trim($("#create-surname").val())
                var appellation = $("#create-call").val()
                var email = $.trim($("#create-email").val())
                var mphone = $.trim($("#create-mphone").val())
                var job = $.trim($("#create-job").val())
                var description = $.trim($("#create-describeContacts").val())
                var contactSummary = $.trim($("#create-contactSummaryContacts").val())
                var nextContactTime = $("#create-nextContactTimeContacts").val()
                var address = $.trim($("#create-address").val())
                //拦截非法输入
                if (fullName == "") {
                    alert("姓名不能为空！")
                    return
                }
                if (mphone != null && mphone != "") {
                    var regExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/
                    if (!regExp.test(mphone)) {
                        alert("输入手机号码不合法！")
                        return
                    }
                }
                if (email != null && email != "") {
                    var regExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/
                    if (!regExp.test(email)) {
                        alert("输入邮箱不合法！")
                        return
                    }
                }
                //数据无误，发送ajax请求
                $.ajax({
                    url: "workbench/customer/saveCreateContacts",
                    data: {
                        owner:owner,
                        source:source,
                        customerId:customerId,
                        fullName:fullName,
                        appellation:appellation,
                        email:email,
                        mphone:mphone,
                        job:job,
                        description:description,
                        contactSummary:contactSummary,
                        nextContactTime:nextContactTime,
                        address:address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            var contacts = data.obj
                            //收集参数
                            var id = contacts.id
                            var fullName = contacts.fullName
                            var email = contacts.email == null || contacts.email == "" ?"未知":contacts.email
                            var mphone = contacts.mphone == null || contacts.mphone == "" ? "未知":contacts.mphone
                            var html = ""
                            html += "<tr id=\"contactsId_" + id + "\">"
                            html += "<td><a href=\"workbench/contacts/queryContactsForDetail.do?contactsId="+ id +"\" style=\"text-decoration: none;\">" + fullName + "</a></td>"
                            html += "<td>" + email + "</td>"
                            html += "<td>" + mphone + "</td>"
                            html += "<td><a href=\"javascript:void(0);\" name=\"deleteContacts\" contactsId=\"" + id + "\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>"
                            html += "</tr>"
                            $("#customerContactsList").append(html)
                            alert(data.message)
                            //隐藏模态窗口
                            $("#createContactsModal").modal("hide")
                            //重置创建表单
                            $("#createContactsForm").get(0).reset()
                        } else {
                            //保存失败
                            alert(data.message)
                        }
                    }
                })
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

            //给创建交易“客户名称”文本框绑定键起事件
            $("#create-accountName").typeahead({
                source: function (jquery, process) {
                    $.ajax({
                        url: 'workbench/transaction/queryCustomerName',
                        data: {
                            customerName: jquery
                        },
                        type: 'post',
                        dataType: 'json',
                        success: function (data) {
                            process(data)
                        }
                    })
                }
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
                var customerName = $("#create-accountName").val()
                //拦截输入值为空
                if (fullName == null || fullName == "") {
                    $("#contactsList").html("")
                    return
                }
                $.ajax({
                    url: "workbench/transaction/queryContacts",
                    data: {
                        fullName: fullName,
                        customerName:customerName
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
                    url: "workbench/customer/saveCreateTransaction",
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
                            <input type="text" class="form-control" id="create-accountName" value="${customer.name}" readonly>
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
                                href="javascript:void(0);" id="openCreateContactsRelationBtn"><span
                                class="glyphicon glyphicon-search"></span></a></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsName" placeholder="点击“放大镜”搜索"
                                   readonly>
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
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
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

<!-- 创建联系人的模态窗口 -->
<div class="modal fade" id="createContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createContactsForm">

                    <div class="form-group">
                        <label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-contactsOwner">
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-clueSourceContacts" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueSourceContacts">
                                <option></option>
                                <c:forEach items="${sourceList}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-surname">
                        </div>
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-call">
                                <option></option>
                                <c:forEach items="${appellationList}" var="appellation">
                                    <option value="${appellation.id}">${appellation.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-job">
                        </div>
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-mphone">
                        </div>
                    </div>

                    <div class="form-group" style="position: relative;">
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-email">
                        </div>
                        <label for="create-customerName" class="col-sm-2 control-label">客户名称
                        <span style="font-size: 15px; color: red;">*</span>
                        </label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-customerName" readonly>
                        </div>
                    </div>

                    <div class="form-group" style="position: relative;">
                        <label for="create-describeContacts" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describeContacts"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummaryContacts" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummaryContacts"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTimeContacts" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="date" class="form-control" id="create-nextContactTimeContacts">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveCreateContactsBtn">保存</button>
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
        <h3>${customer.name} <small><a href="https://${customer.website}"
                                       target="_blank">${customer.website}</a></small></h3>
    </div>
</div>

<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.name}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.website}">
                    未知
                </c:if>
                <c:if test="${not empty customer.website}">
                    ${customer.website}
                </c:if>
            </b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>
                <c:if test="${empty customer.phone}">
                    未知
                </c:if>
                <c:if test="${not empty customer.phone}">
                    ${customer.phone}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${customer.createBy}&nbsp;&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${customer.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.editBy}">
                    无
                </c:if>
                <c:if test="${not empty customer.editBy}">
                    ${customer.editBy}
                </c:if>
                &nbsp;
            </b>
            <small style="font-size: 10px; color: gray;">${customer.editTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.contactSummary}">
                    未知
                </c:if>
                <c:if test="${not empty customer.contactSummary}">
                    ${customer.contactSummary}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.nextContactTime}">
                    待定
                </c:if>
                <c:if test="${not empty customer.nextContactTime}">
                    ${customer.nextContactTime}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.description}">
                    未知
                </c:if>
                <c:if test="${not empty customer.description}">
                    ${customer.description}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <c:if test="${empty customer.address}">
                    未知
                </c:if>
                <c:if test="${not empty customer.address}">
                    ${customer.address}
                </c:if>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkDivList" style="position: relative; top: 10px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${customerRemarks}" var="remark">
        <div id="remarkDiv_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">客户</font> <font color="gray">-</font> <b>${customer.name}</b> <small
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
                <button type="button" class="btn btn-primary" id="saveCreateCustomerRemarkBtn">保存</button>
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
            <table id="activityTable2" class="table table-hover" style="width: 900px;">
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
                <c:forEach items="${transactions}" var="transaction">
                    <tr id="tran_${transaction.id}">
                        <td><a href="workbench/transaction/queryTransactionForDetail.do?tranId=${transaction.id}" style="text-decoration: none;">${transaction.name}</a></td>
                        <td>
                            <c:if test="${empty transaction.money}">
                                待定
                            </c:if>
                            <c:if test="${not empty transaction.money}">
                                ${transaction.money}￥
                            </c:if>
                        </td>
                        <td>${transaction.stage}</td>
                        <td>${transaction.possibility}</td>
                        <td>${transaction.expectedDate}</td>
                        <td>
                            <c:if test="${empty transaction.type}">
                                待定
                            </c:if>
                            <c:if test="${not empty transaction.type}">
                                ${transaction.type}
                            </c:if>
                        </td>
                        <td><a href="javascript:void(0);" style="text-decoration: none;" name="deleteTransaction" tranId="${transaction.id}"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
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

<!-- 联系人 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>联系人</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTableList" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>邮箱</td>
                    <td>手机</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="customerContactsList">
                <c:forEach items="${contactsList}" var="contacts">
                    <tr id="contactsId_${contacts.id}">
                        <td><a href="workbench/contacts/queryContactsForDetail.do?contactsId=${contacts.id}" style="text-decoration: none;">${contacts.fullName}</a></td>
                        <td>
                            <c:if test="${empty contacts.email}">
                                未知
                            </c:if>
                            <c:if test="${not empty contacts.email}">
                                ${contacts.email}
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${empty contacts.mphone}">
                                未知
                            </c:if>
                            <c:if test="${not empty contacts.mphone}">
                                ${contacts.mphone}
                            </c:if>
                        </td>
                        <td><a href="javascript:void(0);" name="deleteContacts" contactsId="${contacts.id}" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <div>
            <a href="javascript:void(0);" data-toggle="modal" id="createContactsBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
        </div>
    </div>
</div>

<div style="height: 200px;"></div>
</body>
</html>