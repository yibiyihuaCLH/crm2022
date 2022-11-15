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
    <!--引入echarts插件-->
    <script type="text/javascript" src="jquery/echars/echarts.min.js"></script>
    <script type="text/javascript">
        $(function () {
            //页面加载完，发送ajax请求获取第一页前十条交易数据
            queryTransactionByConditionForPage(1, 10)

            //设置“创建联系人”和“修改联系人”中“下次联系时间”和“预计成交日期”最早从当天选择
            selectDateAfterToday("create-nextContactTime")
            selectDateAfterToday("edit-nextContactTime")
            selectDateAfterToday("create-expectedClosingDate")
            selectDateAfterToday("edit-expectedClosingDate")

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
                $("#tranList input[type='checkbox']").prop("checked", this.checked)
            })
            $("#tranList").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#tranList input[type='checkbox']").size() == $("#tranList input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {//如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给“查询”按钮绑定单击事件
            $("#queryTransactionBtn").click(function () {
                queryTransactionByConditionForPage(1, $("#rows_per_page_page").val())
            })

            //根据查询条件分页查询（方法）
            function queryTransactionByConditionForPage(pageNo, pageSize) {
                var owner = $.trim($("#query-owner").val())
                var name = $.trim($("#query-name").val())
                var customerId = $.trim($("#query-customer").val())
                var stage = $("#query-stage").val()
                var type = $("#query-type").val()
                var source = $("#query-source").val()
                var contactsId = $.trim($("#query-contacts").val())
                $.ajax({
                    url: "workbench/transaction/queryTransactionByConditionForPageAndQueryCountByCondition",
                    data: {
                        owner: owner,
                        name: name,
                        customerId: customerId,
                        stage: stage,
                        type: type,
                        source: source,
                        contactsId: contactsId,
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
                        var tranList = data.tranList
                        for (let i = 0; i < tranList.length; i++) {
                            var transaction = tranList[i]
                            var id = transaction.id
                            var owner = transaction.owner
                            var name = transaction.name
                            var customer = transaction.customerId
                            var stage = transaction.stage
                            var type = transaction.type == null || transaction.type == "" ? "待定" : transaction.type
                            var source = transaction.source == null || transaction.source == "" ? "未知" : transaction.source
                            var contacts = transaction.contactsId == null || transaction.contactsId == "" ? "待定" : transaction.contactsId
                            html += "<tr>"
                            html += "<td><input type=\"checkbox\" value=\"" + id + "\"/></td>"
                            html += "<td><a style=\"text-decoration: none; cursor: pointer;\""
                            html += "onclick=\"window.location.href='workbench/transaction/queryTransactionForDetail.do?tranId=" + id + "';\">" + name + "</a></td>"
                            html += "<td>" + customer + "</td>"
                            html += "<td>" + contacts + "</td>"
                            html += "<td>" + owner + "</td>"
                            html += "<td>" + stage + "</td>"
                            html += "<td>" + type + "</td>"
                            html += "<td>" + source + "</td>"
                            html += "</tr>"
                        }
                        $("#tranList").html(html)

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
                                queryTransactionByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            }
                        })
                    }
                })
            }

            //初始化修改交易模态窗口中表单数据
            /*-----------------------------------------------------------------------------------*/
            //给修改交易“阶段”绑定发生改变事件
            $("#edit-transactionStage").change(function () {
                var stage = $("#edit-transactionStage option:selected").text()
                if (stage == null || stage == "") {
                    $("#edit-possibility").val("")
                    return
                }
                $.ajax({
                    url: "workbench/transaction/getPossibility",
                    data: {
                        stage: stage
                    },
                    type: "post",
                    dataType: "text",
                    success: function (data) {
                        $("#edit-possibility").val(data)
                    }
                })
            })

            //给修改交易“客户名称”文本框绑定键起事件
            $("#edit-accountName").typeahead({
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


            //给修改交易“关联市场活动”按钮绑定单击事件
            $("#openEditActivityRelationBtn").click(function () {
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

            //给修改交易“关联联系人”按钮绑定单击事件
            $("#openEditContactsRelationBtn").click(function () {
                if ($("#edit-accountName").val() == null || $("#edit-accountName").val() == "") {
                    alert("请先填写客户名称！")
                    return
                }
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
                var customerName = $("#edit-accountName").val()
                $.ajax({
                    url: "workbench/transaction/queryContacts",
                    data: {
                        fullName: fullName,
                        customerName: customerName
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
            //给“修改”交易按钮绑定单击事件
            $("#openEditTranBtn").click(function () {
                var checkedIds = $("#tranList input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("请选择交易")
                    return
                }
                if (checkedIds.length > 1) {
                    alert("最多选择一条交易")
                    return
                }
                //获取选中的复选框id值
                var id = checkedIds[0].value
                $.ajax({
                    url: "workbench/transaction/queryTransaction",
                    data: {
                        id: id
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var owner = data.owner
                        var money = data.money
                        var name = data.name
                        var expectedDate = data.expectedDate
                        var customer = data.customer
                        var stage = data.stage
                        var type = data.type
                        var source = data.source
                        var activity = data.activity
                        var contacts = data.contacts
                        var description = data.description
                        var contactSummary = data.contactSummary
                        var nextContactTime = data.nextContactTime
                        var possibility = data.possibility
                        //判断所有者是否存在（账号未锁定）
                        var ownerValue
                        if (isExistOption("edit-transactionOwner", owner)) {
                            $("#edit-transactionOwner option[value=lockState]").text("")
                            ownerValue = owner
                        } else {
                            //添加一条错误信息选项
                            $("#edit-transactionOwner option[value=lockState]").text("当前线索所有者账号已锁定")
                            ownerValue = "lockState"
                        }
                        //初始化选中的交易记录修改模态窗口
                        $("#edit-transactionOwner").val(ownerValue)
                        $("#edit-amountOfMoney").val(money)
                        $("#edit-transactionName").val(name)
                        $("#edit-expectedClosingDate").val(expectedDate)
                        $("#edit-accountName").val(customer)
                        $("#edit-transactionStage").val(stage)
                        $("#originStage").val(stage)
                        $("#edit-transactionType").val(type)
                        $("#edit-clueSource").val(source)
                        $("#edit-activitySrc").val(activity)
                        $("#edit-contactsName").val(contacts)
                        $("#edit-describe").val(description)
                        $("#edit-contactSummary").val(contactSummary)
                        $("#edit-nextContactTime").val(nextContactTime)
                        $("#edit-possibility").val(possibility)
                        if (stage == "29805c804dd94974b568cfc9017b2e4c") {
                            $("#edit-transactionStage").attr("disabled", "disabled")
                        } else {
                            $("#edit-transactionStage").removeAttr("disabled")
                        }
                        //弹出修改市场活动的模态窗口
                        $("#editTranModal").modal("show")
                    }
                })
            })

            //判断select中是否存在值为value的项（方法）
            function isExistOption(id, value) {
                var isExist = false
                var count = $('#' + id).find('option').length
                for (var i = 0; i < count; i++) {
                    if ($('#' + id).get(0).options[i].value == value) {
                        isExist = true
                        break
                    }
                }
                return isExist
            }

            //给“更新”按钮绑定单击事件
            $("#saveEditContactsBtn").click(function () {
                //拦截非法所有者输入
                if ($("#edit-transactionOwner").val() == "lockState") {
                    if ($("#edit-transactionOwner option[value=lockState]").text() == "") {
                        alert("所有者不能为空!")
                    } else {
                        alert("请选择其他所有者！")
                    }
                    return
                }
                //判断是否需要添加交易历史
                var createHistory
                var stage = $("#edit-transactionStage").val()
                if (stage != $("#originStage").val()) {
                    createHistory = true
                } else {
                    createHistory = false
                }
                //收集联系人参数
                var checkedIds = $("#tranList input[type='checkbox']:checked")
                var id = checkedIds[0].value
                var owner = $("#edit-transactionOwner").val()
                var money = $.trim($("#edit-amountOfMoney").val())
                var name = $.trim($("#edit-transactionName").val())
                var expectedDate = $("#edit-expectedClosingDate").val()
                var customerId = $.trim($("#edit-accountName").val())
                var type = $("#edit-transactionType").val()
                var source = $("#edit-clueSource").val()
                var activityId = $("#edit-activitySrc").attr("activityId")
                var contactsId = $("#edit-contactsName").attr("contactsId")
                var description = $("#edit-describe").val()
                var contactSummary = $("#edit-contactSummary").val()
                var nextContactTime = $("#edit-nextContactTime").val()
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
                //发送ajax保存修改
                $.ajax({
                    url: "workbench/transaction/saveEditTransaction",
                    data: {
                        id: id,
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
                        nextContactTime: nextContactTime,
                        createHistory: createHistory
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code = "1") {
                            //更新成功，刷新市场活动记录
                            queryTransactionByConditionForPage($("#page").bs_pagination("getOption", "currentPage"), $("#rows_per_page_page").val())
                            //清空全选框
                            $("#checkAll").prop("checked", false)
                            // 关闭模态窗口
                            $("#editTranModal").modal("hide")
                        }
                        alert(data.message)
                    }
                })
            })

            //给“删除”按钮绑定单击事件
            $("#deleteTranBtn").click(function () {
                var checkedIds = $("#tranList input[type='checkbox']:checked")
                //判断删除条数是否为空
                if (checkedIds.length == 0) {
                    alert("至少删除一条交易")
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
                        url: "workbench/transaction/deleteTransaction",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,刷新市场活动列表
                                queryTransactionByConditionForPage(1, $("#rows_per_page_page").val())
                                //全选复选框取消选中
                                $("#checkAll").prop("checked", false)
                            }
                            alert(data.message)
                        }
                    })
                }
            })

            //给“交易列表”链接绑定单击事件
            $("#charBtn").click(function () {
                $.ajax({
                    url: "workbench/transaction/queryCountOfTranGroupByStage",
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        // 基于准备好的dom，初始化echarts实例
                        var myChart = echarts.init(document.getElementById('charDiv'));
                        // 指定图表的配置项和数据
                        var option = {
                            title: {
                                text: '交易统计图表',
                                subtext: '交易表中各个阶段的数量'
                            },
                            tooltip: {
                                trigger: 'item',
                                formatter: "{a} <br/>{b} : {c}"
                            },
                            toolbox: {
                                feature: {
                                    dataView: {readOnly: false},
                                    restore: {},
                                    saveAsImage: {}
                                }
                            },
                            series: [
                                {
                                    name: '数据量',
                                    type: 'funnel',
                                    left: '10%',
                                    width: '80%',
                                    label: {
                                        formatter: '{b}'
                                    },
                                    labelLine: {
                                        show: true
                                    },
                                    itemStyle: {
                                        opacity: 0.7
                                    },
                                    emphasis: {
                                        label: {
                                            position: 'inside',
                                            formatter: '{b}: {c}'
                                        }
                                    },
                                    data: data
                                }
                            ]
                        }
                        // 使用刚指定的配置项和数据显示图表。
                        myChart.setOption(option)
                        //打开图表模态窗口
                        $("#charModal").modal("show")
                    }
                })
            })

        })

    </script>
</head>
<body>
<!-- 修改交易的模态窗口 -->
<div class="modal fade" id="editTranModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="editModalLabel">修改交易</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" style="position: relative; top: 5px;">
                    <div class="form-group">
                        <label for="edit-transactionOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-transactionOwner">
                                <option value="lockState"></option>
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-amountOfMoney" class="col-sm-2 control-label">金额</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-amountOfMoney">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-transactionName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-transactionName">
                        </div>
                        <label for="edit-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="edit-expectedClosingDate">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-accountName" class="col-sm-2 control-label">客户名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-accountName"
                                   placeholder="支持自动补全，输入客户不存在则新建">
                        </div>
                        <label for="edit-transactionStage" class="col-sm-2 control-label">阶段<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-transactionStage">
                                <option></option>
                                <c:forEach items="${stageList}" var="stage">
                                    <option value="${stage.id}">${stage.value}</option>
                                </c:forEach>
                            </select>
                            <input type="hidden" id="originStage">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-transactionType" class="col-sm-2 control-label">类型</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-transactionType">
                                <option></option>
                                <c:forEach items="${typeList}" var="type">
                                    <option value="${type.id}">${type.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-possibility" placeholder="请选择“阶段”"
                                   readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueSource">
                                <option></option>
                                <c:forEach items="${sourceList}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a
                                href="javascript:void(0);" id="openEditActivityRelationBtn"><span
                                class="glyphicon glyphicon-search"></span></a></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-activitySrc" activityId=""
                                   placeholder="点击“放大镜”搜索" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a
                                href="javascript:void(0);" id="openEditContactsRelationBtn"><span
                                class="glyphicon glyphicon-search"></span></a></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-contactsName" placeholder="点击“放大镜”搜索"
                                   readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 70%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                        <div class="col-sm-10" style="width: 70%;">
                            <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="edit-nextContactTime">
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

<!-- 图表模态窗口 -->
<div class="modal fade" id="charModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
        <div class="modal-content">
            <div class="modal-body" id="charDiv" style="width: 820px;height: 550px"></div>
            <div class="modal-footer" >
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
            </div>
        </div>
    </div>
</div>

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <a href="javascript:void(0);" id="charBtn">
                <span><h3>交易列表</h3></span>
            </a>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="query-name">
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
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" type="text" id="query-contacts">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="query-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select class="form-control" id="query-stage">
                            <option></option>
                            <c:forEach items="${stageList}" var="stage">
                                <option value="${stage.id}">${stage.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">类型</div>
                        <select class="form-control" id="query-type">
                            <option></option>
                            <c:forEach items="${typeList}" var="type">
                                <option value="${type.id}">${type.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="query-source">
                            <option></option>
                            <c:forEach items="${sourceList}" var="source">
                                <option value="${source.id}">${source.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryTransactionBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" id="openEditTranBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteTranBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>客户名称</td>
                    <td>联系人名称</td>
                    <td>所有者</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>来源</td>
                </tr>
                </thead>
                <tbody id="tranList"></tbody>
            </table>
            <div id="page"></div>
        </div>

    </div>

</div>
</body>
</html>