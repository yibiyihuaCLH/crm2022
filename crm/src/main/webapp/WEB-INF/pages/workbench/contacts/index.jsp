<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <%--分页插件--%>
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
    <%--自动补全插件--%>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

    <script type="text/javascript">
        $(function () {
            //页面加载完，发送ajax请求获取第一页前十条联系人数据
            queryContactsByConditionForPage(1, 10)

            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation()
            })

            //设置“创建联系人”和“修改联系人”中“下次联系时间”最早从当天选择
            selectDateAfterToday("create-nextContactTime")
            selectDateAfterToday("edit-nextContactTime")

            //input中type为date的格式，只能选择今天之后的日期（方法）
            function selectDateAfterToday(dateSelector) {
                var date = new Date()
                var year = date.getFullYear()
                var month = date.getMonth() + 1
                if (month < 10) {
                    month = '0' + month
                }
                var day = date.getDate()
                if (day < 10) {
                    day = '0' + day
                }
                var time = year + '-' + month + '-' + day
                $("#" + dateSelector).attr("min", time)
            }

            //给"全选"按钮添加单击事件
            $("#checkAll").click(function () {
                $("#contactsList input[type='checkbox']").prop("checked", this.checked)
            })
            $("#contactsList").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#contactsList input[type='checkbox']").size() == $("#contactsList input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {//如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给“查询”按钮绑定单击事件
            $("#queryContactsBtn").click(function () {
                queryContactsByConditionForPage(1,$("#rows_per_page_page").val())
            })

            //根据查询条件分页查询（方法）
            function queryContactsByConditionForPage(pageNo, pageSize) {
                var owner = $("#query-owner").val()
                var fullName = $("#query-fullName").val()
                var customerId = $("#query-customer").val()
                var source = $("#query-source").val()
                $.ajax({
                    url: "workbench/contacts/queryContactsByConditionForPageAndQueryCountByCondition",
                    data: {
                        owner: owner,
                        fullName: fullName,
                        customerId: customerId,
                        source: source,
                        pageNo: pageNo,
                        pageSize: pageSize
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        //获取记录总条数
                        $("#totalRows").text(data.totalRows)
                        //获取记录
                        var html = ""
                        var contactsList = data.contactsList
                        for (let i = 0; i < contactsList.length; i++) {
                            var contacts = contactsList[i]
                            var id = contacts.id
                            var owner = contacts.owner
                            var fullName = contacts.fullName
                            var customer = contacts.customerId == null || contacts.customerId == "" ? "待定" : contacts.customerId
                            var source = contacts.source == null || contacts.source == "" ? "未知" : contacts.source

                            html += "<tr>"
                            html += "<td><input type=\"checkbox\" value=\"" + id + "\"/></td>"
                            html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/queryContactsForDetail.do?contactsId=" + id + "';\">" + fullName + "</a></td>"
                            html += "<td>" + customer + "</td>"
                            html += "<td>" + owner + "</td>"
                            html += "<td>" + source + "</td>"
                            html += "</tr>"
                        }
                        $("#contactsList").html(html)

                        //计算总页数
                        var totalPages = 1;
                        if (data.totalRows % pageSize == 0) {
                            totalPages = data.totalRows / pageSize;
                        } else {
                            totalPages = parseInt(data.totalRows / pageSize) + 1;
                        }
                        $("#page").bs_pagination({
                            currentPage: pageNo,//当前页号,相当于pageNo

                            rowsPerPage: pageSize,//每页显示条数,相当于pageSize
                            totalRows: data.totalRows,//总条数
                            totalPages: totalPages,  //总页数,必填参数.

                            visiblePageLinks: 5,//最多可以显示的卡片数

                            showGoToPage: true,//是否显示"跳转到"部分,默认true--显示
                            showRowsPerPage: true,//是否显示"每页显示条数"部分。默认true--显示
                            showRowsInfo: true,//是否显示记录的信息，默认true--显示

                            //用户每次切换页号，都自动触发本函数;
                            //每次返回切换页号之后的pageNo和pageSize
                            onChangePage: function (event, pageObj) {
                                //清空全选框
                                $("#checkAll").prop("checked", false)
                                //分页查询
                                queryContactsByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            }
                        })
                    }
                })
            }

            //给“删除”按钮绑定单击事件
            $("#deleteContactsBtn").click(function () {
                var checkedIds = $("#contactsList input[type='checkbox']:checked")
                //判断删除条数是否为空
                if (checkedIds.length == 0) {
                    alert("至少删除一条联系人")
                    return
                }
                if (window.confirm("确认是否删除？")) {
                    //拼接data数据
                    var ids = ""
                    for (let i = 0; i < checkedIds.length; i++) {
                        ids += "id=" + checkedIds[i].value + "&"
                    }
                    ids = ids.substring(0, ids.length - 1)
                    //发送ajax请求删除市场活动
                    $.ajax({
                        url: "workbench/contacts/deleteContacts",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,刷新市场活动列表
                                queryContactsByConditionForPage(1, $("#rows_per_page_page").val())
                                //全选复选框取消选中
                                $("#checkAll").prop("checked", false)
                            }
                            alert(data.message)
                        }
                    })
                }
            })

            //给创建联系人“客户名称”文本框绑定键起事件
            $("#create-customerName").typeahead({
                source: function (jquery, process) {
                    $.ajax({
                        url: 'workbench/contacts/queryCustomerName',
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


            //给“创建”按钮添加单击事件
            $("#createContactsBtn").click(function () {
                $("#create-contactsOwner  option[value='${sessionScope.sessionUser.id}'] ").attr("selected", true)
                //弹出创建联系人的模态窗口
                $("#createContactsModal").modal("show")
            })

            //给创建联系人模态窗口“保存”按钮添加单击事件
            $("#saveCreateContacts").click(function () {
                var owner = $("#create-contactsOwner").val()
                var source = $("#create-clueSource").val()
                var customerId = $.trim($("#create-customerName").val())
                var fullName = $.trim($("#create-surname").val())
                var appellation = $("#create-call").val()
                var email = $.trim($("#create-email").val())
                var mphone = $.trim($("#create-mphone").val())
                var job = $.trim($("#create-job").val())
                var description = $.trim($("#create-describe").val())
                var contactSummary = $.trim($("#create-contactSummary").val())
                var nextContactTime = $("#create-nextContactTime").val()
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
                    url: "workbench/contacts/saveCreateContacts",
                    data: {
                        owner: owner,
                        source: source,
                        customerId: customerId,
                        fullName: fullName,
                        appellation: appellation,
                        email: email,
                        mphone: mphone,
                        job: job,
                        description: description,
                        contactSummary: contactSummary,
                        nextContactTime: nextContactTime,
                        address: address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            //保存成功，刷新市场活动列表
                            queryContactsByConditionForPage(1, $("#rows_per_page_page").val())
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

            //给“修改”按钮绑定单击事件
            $("#editContactsBtn").click(function () {
                var checkedIds = $("#contactsList input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("请选择联系人")
                    return
                }
                if (checkedIds.length > 1) {
                    alert("最多选择一位联系人")
                    return
                }
                //获取选中的复选框id值
                var id = checkedIds[0].value
                $.ajax({
                    url: "workbench/contacts/queryContacts",
                    data: {
                        id: id
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var owner = data.owner
                        var source = data.source
                        var customerName = data.customerId
                        var fullName = data.fullName
                        var appellation = data.appellation
                        var email = data.email
                        var mphone = data.mphone
                        var job = data.job
                        var description = data.description
                        var contactSummary = data.contactSummary
                        var nextContactTime = data.nextContactTime
                        var address = data.address
                        //判断所有者是否存在（账号未锁定）
                        var ownerValue
                        if (isExistOption("edit-contactsOwner", owner)) {
                            $("#edit-contactsOwner option[value=lockState]").text("")
                            ownerValue = owner
                        } else {
                            //添加一条错误信息选项
                            $("#edit-contactsOwner option[value=lockState]").text("当前线索所有者账号已锁定")
                            ownerValue = "lockState"
                        }
                        //初始化选中的联系人记录修改模态窗口
                        $("#edit-contactsOwner").val(ownerValue)
                        $("#edit-clueSource").val(source)
                        $("#edit-customerName").val(customerName)
                        $("#edit-surname").val(fullName)
                        $("#edit-call").val(appellation)
                        $("#edit-email").val(email)
                        $("#edit-mphone").val(mphone)
                        $("#edit-job").val(job)
                        $("#edit-describe").val(description)
                        $("#edit-contactSummary").val(contactSummary)
                        $("#edit-nextContactTime").val(nextContactTime)
                        $("#edit-address").val(address)
                        //弹出修改市场活动的模态窗口
                        $("#editContactsModal").modal("show")
                    }
                })
            })

            //判断select中是否存在值为value的项（方法）
            function isExistOption(id, value) {
                var isExist = false
                var count = $('#' + id).find('option').length;
                for (var i = 0; i < count; i++) {
                    if ($('#' + id).get(0).options[i].value == value) {
                        isExist = true
                        break
                    }
                }
                return isExist;
            }

            //给修改联系人“客户名称”文本框绑定键起事件
            $("#edit-customerName").typeahead({
                source: function (jquery, process) {
                    $.ajax({
                        url: 'workbench/contacts/queryCustomerName',
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

            //给“更新”按钮绑定单击事件
            $("#saveEditContactsBtn").click(function () {
                //拦截非法所有者输入
                if ($("#edit-contactsOwner").val() == "lockState") {
                    if ($("#edit-contactsOwner option[value=lockState]").text() == "") {
                        alert("所有者不能为空!")
                    } else {
                        alert("请选择其他所有者！")
                    }
                    return
                }
                //收集联系人参数
                var checkedIds = $("#contactsList input[type='checkbox']:checked")
                var id = checkedIds[0].value
                var owner = $("#edit-contactsOwner").val()
                var source = $("#edit-clueSource").val()
                var customerId = $.trim($("#edit-customerName").val())
                var fullName = $.trim($("#edit-surname").val())
                var appellation = $("#edit-call").val()
                var email = $.trim($("#edit-email").val())
                var mphone = $.trim($("#edit-mphone").val())
                var job = $.trim($("#edit-job").val())
                var description = $.trim($("#edit-describe").val())
                var contactSummary = $.trim($("#edit-contactSummary").val())
                var nextContactTime = $("#edit-nextContactTime").val()
                var address = $.trim($("#edit-address").val())
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
                //发送ajax保存修改
                $.ajax({
                    url: "workbench/contacts/saveEditContacts",
                    data: {
                        id: id,
                        owner: owner,
                        source: source,
                        customerId: customerId,
                        fullName: fullName,
                        appellation: appellation,
                        email: email,
                        mphone: mphone,
                        job: job,
                        description: description,
                        contactSummary: contactSummary,
                        nextContactTime: nextContactTime,
                        address: address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code = "1") {
                            //更新成功，刷新市场活动记录
                            queryContactsByConditionForPage($("#page").bs_pagination("getOption", "currentPage"), $("#rows_per_page_page").val())
                            //清空全选框
                            $("#checkAll").prop("checked", false)
                            // 关闭模态窗口
                            $("#editContactsModal").modal("hide")
                        }
                        alert(data.message)
                    }
                })
            })
        })
    </script>
</head>
<body>
<!-- 创建联系人的模态窗口 -->
<div class="modal fade" id="createContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createContactsForm">

                    <div class="form-group">
                        <label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-contactsOwner">
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueSource">
                                <option></option>
                                <c:forEach items="${sources}" var="source">
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
                                <c:forEach items="${appellations}" var="appellation">
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
                        <label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-customerName"
                                   placeholder="支持自动补全，输入客户不存在则新建">
                        </div>
                    </div>

                    <div class="form-group" style="position: relative;">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="date" class="form-control" id="create-nextContactTime">
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
                <button type="button" class="btn btn-primary" id="saveCreateContacts">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改联系人的模态窗口 -->
<div class="modal fade" id="editContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-contactsOwner">
                                <option value="lockState"></option>
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueSource">
                                <option></option>
                                <c:forEach items="${sources}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname" value="李四">
                        </div>
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option></option>
                                <c:forEach items="${appellations}" var="appellation">
                                    <option value="${appellation.id}">${appellation.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job" value="CTO">
                        </div>
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone" value="12345678901">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
                        </div>
                        <label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-customerName"
                                   placeholder="支持自动补全，输入客户不存在则新建" value="动力节点">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">这是一条线索的描述信息</textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="date" class="form-control" id="edit-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveEditContactsBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>联系人列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">姓名</div>
                        <input class="form-control" type="text" id="query-fullName">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input class="form-control" type="text" id="query-customer">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="query-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="query-source">
                            <option></option>
                            <c:forEach items="${sources}" var="source">
                                <option value="${source.id}">${source.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryContactsBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createContactsBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editContactsBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteContactsBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>姓名</td>
                    <td>客户名称</td>
                    <td>所有者</td>
                    <td>来源</td>
                </tr>
                </thead>
                <tbody id="contactsList"></tbody>
            </table>
            <div id="page"></div>
        </div>

    </div>

</div>
</body>
</html>