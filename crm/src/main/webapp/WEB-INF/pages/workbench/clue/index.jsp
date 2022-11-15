<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<html>
<head>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet"/>
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
            //页面加载完成，分页查询线索
            queryClueByConditionForPage(1,10)

            $("#create-company").typeahead({
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
            $("#edit-company").typeahead({
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

            //设置“创建线索”和“修改线索”中“下次联系时间”最早从当天选择
            selectDateAfterToday("create-nextContactTime")
            selectDateAfterToday("edit-nextContactTime")
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

            //给"全选"按钮添加单击事件
            $("#checkAll").click(function () {
                $("#clueList input[type='checkbox']").prop("checked", this.checked)
            })
            $("#clueList").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#clueList input[type='checkbox']").size() == $("#clueList input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {
                    //如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给“查询”按钮绑定单击事件
            $("#queryClueByConditionBtn").click(function () {
                queryClueByConditionForPage(1,$("#rows_per_page_page").val())
            })

            //根据查询条件分页查询（方法）
            function queryClueByConditionForPage(pageNo, pageSize) {
                //获取表单信息
                var fullName = $("#queryByFullName").val()
                var company = $("#queryByCompany").val()
                var phone = $("#queryByPhone").val()
                var source = $("#queryBySource").val()
                var owner = $("#queryByOwner").val()
                var mphone = $("#queryByMphone").val()
                var state = $("#queryByState").val()
                $.ajax({
                    url:"workbench/clue/queryClueByConditionForPageAndTotalRow",
                    data:{
                        fullName:fullName,
                        company:company,
                        phone:phone,
                        source:source,
                        owner:owner,
                        mphone:mphone,
                        state: state,
                        pageNo:pageNo,
                        pageSize:pageSize
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        var clues = data.clues
                        var html = ""
                        for (let i = 0; i < clues.length; i++) {
                            var clue = clues[i]
                            //获取相应信息
                            var id = clue.id
                            var fullName = clue.fullName
                            var appellation = clue.appellation == null ? "":clue.appellation
                            var company = clue.company
                            var phone = clue.phone == null || clue.phone == "" ? "未知":clue.phone
                            var mphone = clue.mphone == null || clue.mphone == "" ? "未知":clue.mphone
                            var source = clue.source == null || clue.source == "" ? "未知":clue.source
                            var owner = clue.owner
                            var state = clue.state == null || clue.state == "" ? "待定":clue.state

                            html += "<tr>"
                            html += "<td><input type=\"checkbox\" value=\""+ id +"\"/></td>"
                            html += "<td><a style=\"text-decoration: none; cursor: pointer;\""
                            html += "onclick=\"window.location.href='workbench/clue/queryClueDetail.do?clueId="+ id +"';\">"+ fullName+ appellation +"</a></td>"
                            html += "<td>"+ company +"</td>"
                            html += "<td>"+ phone +"</td>"
                            html += "<td>"+ mphone +"</td>"
                            html += "<td>"+ owner +"</td>"
                            html += "<td>"+ source +"</td>"
                            html += "<td>"+ state +"</td>"
                            html += "</tr>"
                        }
                        $("#clueList").html(html)

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
                                queryClueByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            }
                        })
                    }
                })
            }
            //给“创建”按钮绑定单击事件
            $("#createClueBtn").click(function () {
                //设置“所有者”默认选项
                $("#create-clueOwner  option[value='${sessionScope.sessionUser.id}']").attr("selected", true)
                //弹出模态窗口
                $("#createClueModal").modal("show")
            })

            //给“保存”按钮绑定单击事件
            $("#saveCreateClueBtn").click(function () {
                var owner = $("#create-clueOwner").val()
                var company = $.trim($("#create-company").val())
                var appellation = $("#create-call").val()
                var fullName = $.trim($("#create-surname").val())
                var job = $.trim($("#create-job").val())
                var email = $.trim($("#create-email").val())
                var phone = $.trim($("#create-phone").val())
                var website = $.trim($("#create-website").val())
                var mphone = $.trim($("#create-mphone").val())
                var state = $("#create-status").val()
                var source = $("#create-source").val()
                var description = $.trim($("#create-describe").val())
                var contactSummary = $.trim($("#create-contactSummary").val())
                var nextContactTime = $.trim($("#create-nextContactTime").val())
                var address = $.trim($("#create-address").val())
                //拦截非法输入
                if (company == null || company == "") {
                    alert("公司不能为空！")
                    return
                }
                if (fullName == null || fullName == "") {
                    alert("姓名不能为空！")
                    return
                }
                if (email != null && email != "") {
                    var regExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/
                    if (!regExp.test(email)) {
                        alert("输入邮箱不合法！")
                        return
                    }
                }
                if (phone != null && phone != "") {
                    var regExp = /0\d{2,3}-\d{7,8}|\(?0\d{2,3}[)-]?\d{7,8}|\(?0\d{2,3}[)-]*\d{7,8}/
                    if (!regExp.test(phone)) {
                        alert("输入公司座机号码不合法！")
                        return
                    }
                }
                if (mphone != null && mphone != "") {
                    var regExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/
                    if (!regExp.test(mphone)) {
                        alert("输入手机号码不合法！")
                        return
                    }
                }
                if (website != null && website != "") {
                    var regExp = /^http:\/\/([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$/
                    if (regExp.test(website)) {
                        alert("输入公司网站不合法！")
                    }
                }
                $.ajax({
                    url:"workbench/clue/saveAddClue",
                    data:{
                        owner:owner,
                        company:company,
                        appellation:appellation,
                        fullName:fullName,
                        job:job,
                        email:email,
                        phone:phone,
                        website:website,
                        mphone:mphone,
                        state:state,
                        source:source,
                        description:description,
                        contactSummary:contactSummary,
                        nextContactTime:nextContactTime,
                        address:address
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if (data.code == "1") {
                            //创建成功，刷新市场活动列表
                            queryClueByConditionForPage(1, $("#rows_per_page_page").val())
                            //弹出信息
                            alert(data.message)
                            //隐藏模态窗口
                            $("#createClueModal").modal("hide")
                            //重置表单
                            $("#createClueForm").get(0).reset()
                        }else {
                            //创建失败，弹出错误信息
                            alert(data.message)
                            $("#createClueModal").modal("show")
                        }
                    }
                })
            })

            //给“修改”按钮绑定单击事件
            $("#editClueBtn").click(function () {
                var checkedIds = $("#clueList input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("请选择线索")
                    return
                }
                if (checkedIds.length > 1) {
                    alert("最多选择一条线索")
                    return
                }
                //获取选中的复选框id值
                var id = checkedIds[0].value
                $.ajax({
                    url: "workbench/clue/queryClue",
                    data: {
                        id: id
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var owner = data.owner
                        var company = data.company
                        var appellation = data.appellation
                        var fullName = data.fullName
                        var job = data.job
                        var email = data.email
                        var phone = data.phone
                        var website = data.website
                        var mphone = data.mphone
                        var state = data.state
                        var source = data.source
                        var description = data.description
                        var contactSummary = data.contactSummary
                        var nextContactTime = data.nextContactTime
                        var address = data.address
                        //判断所有者是否存在（账号未锁定）
                        var ownerValue
                        if (isExistOption("edit-clueOwner", owner)) {
                            $("#edit-clueOwner option[value=lockState]").text("")
                            ownerValue = owner
                        }else {
                            //添加一条错误信息选项
                            $("#edit-clueOwner option[value=lockState]").text("当前线索所有者账号已锁定")
                            ownerValue = "lockState"
                        }
                        //初始化选中的市场活动记录修改模态窗口
                        $("#edit-clueOwner").val(ownerValue)
                        $("#edit-company").val(company)
                        $("#edit-call").val(appellation)
                        $("#edit-surname").val(fullName)
                        $("#edit-job").val(job)
                        $("#edit-email").val(email)
                        $("#edit-phone").val(phone)
                        $("#edit-website").val(website)
                        $("#edit-mphone").val(mphone)
                        $("#edit-status").val(state)
                        $("#edit-source").val(source)
                        $("#edit-describe").val(description)
                        $("#edit-contactSummary").val(contactSummary)
                        $("#edit-nextContactTime").val(nextContactTime)
                        $("#edit-address").val(address)
                        //弹出修改市场活动的模态窗口
                        $("#editClueModal").modal("show")
                    }
                })
            })
            //判断select中是否存在值为value的项（方法）
            function isExistOption(id, value) {
                var isExist = false;
                var count = $('#' + id).find('option').length;
                for (var i = 0; i < count; i++) {
                    if ($('#' + id).get(0).options[i].value == value) {
                        isExist = true;
                        break;
                    }
                }
                return isExist;
            }

            //给“更新”按钮绑定单击事件
            $("#saveEditClueBtn").click(function () {
                //拦截非法所有者输入
                if ($("#edit-clueOwner").val() == "lockState") {
                    if ($("#edit-clueOwner option[value=lockState]").text() == "") {
                        alert("所有者不能为空!")
                    } else {
                        alert("请选择其他所有者！")
                    }
                    return
                }
                //收集线索参数
                var checkedIds = $("#clueList input[type='checkbox']:checked")
                var id = checkedIds[0].value
                var owner = $("#edit-clueOwner").val()
                var company = $.trim($("#edit-company").val())
                var appellation = $("#edit-call").val()
                var fullName = $.trim($("#edit-surname").val())
                var job = $.trim($("#edit-job").val())
                var email = $.trim($("#edit-email").val())
                var phone = $.trim($("#edit-phone").val())
                var website = $.trim($("#edit-website").val())
                var mphone = $.trim($("#edit-mphone").val())
                var state = $("#edit-status").val()
                var source = $("#edit-source").val()
                var description = $.trim($("#edit-describe").val())
                var contactSummary = $.trim($("#edit-contactSummary").val())
                var nextContactTime = $.trim($("#edit-nextContactTime").val())
                var address = $.trim($("#edit-address").val())
                //拦截非法输入
                if (company == null || company == "") {
                    alert("公司不能为空！")
                    return
                }
                if (fullName == null || fullName == "") {
                    alert("姓名不能为空！")
                    return
                }
                if (email != null && email != "") {
                    var regExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/
                    if (!regExp.test(email)) {
                        alert("输入邮箱不合法！")
                        return
                    }
                }
                if (phone != null && phone != "") {
                    var regExp = /0\d{2,3}-\d{7,8}|\(?0\d{2,3}[)-]?\d{7,8}|\(?0\d{2,3}[)-]*\d{7,8}/
                    if (!regExp.test(phone)) {
                        alert("输入公司座机号码不合法！")
                        return
                    }
                }
                if (mphone != null && mphone != "") {
                    var regExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/
                    if (!regExp.test(mphone)) {
                        alert("输入手机号码不合法！")
                        return
                    }
                }
                if (website != null && website != "") {
                    var regExp = /^http:\/\/([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$/
                    if (regExp.test(website)) {
                        alert("输入公司网站不合法！")
                    }
                }
                //发送ajax保存修改
                $.ajax({
                    url: "workbench/clue/saveEditClue",
                    data: {
                        id:id,
                        owner:owner,
                        company:company,
                        appellation:appellation,
                        fullName:fullName,
                        job:job,
                        email:email,
                        phone:phone,
                        website:website,
                        mphone:mphone,
                        state:state,
                        source:source,
                        description:description,
                        contactSummary:contactSummary,
                        nextContactTime:nextContactTime,
                        address:address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code = "1") {
                            //更新成功，刷新市场活动记录
                            queryClueByConditionForPage($("#page").bs_pagination("getOption", "currentPage"), $("#rows_per_page_page").val())
                            //清空全选框
                            $("#checkAll").prop("checked", false)
                            // 关闭模态窗口
                            $("#editClueModal").modal("hide")
                        }
                        alert(data.message)

                    }
                })
            })

            //给删除按钮绑定单击事件
            $("#deleteClueBtn").click(function () {
                var checkedIds = $("#clueList input[type='checkbox']:checked")
                //判断删除条数是否为空
                if (checkedIds.length == 0) {
                    alert("至少删除一条市场活动")
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
                        url: "workbench/clue/deleteClue",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,刷新市场活动列表
                                queryClueByConditionForPage(1, $("#rows_per_page_page").val())
                                //全选复选框取消选中
                                $("#checkAll").prop("checked", false)
                            }
                            alert(data.message)
                        }
                    })
                }
            })

        })

    </script>
</head>
<body>

<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">创建线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createClueForm">

                    <div class="form-group">
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueOwner">
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-call">
                                <option selected></option>
                                <c:forEach items="${appellations}" var="appellation">
                                    <option value="${appellation.id}">${appellation.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-surname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-job">
                        </div>
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-mphone">
                        </div>
                        <label for="create-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-status">
                                <option selected></option>
                                <c:forEach items="${states}" var="state">
                                    <option value="${state.id}">${state.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-source">
                                <option selected></option>
                                <c:forEach items="${sources}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">线索描述</label>
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
                <button type="button" class="btn btn-primary" id="saveCreateClueBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueOwner">
                                <option value="lockState"></option>
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option selected></option>
                                <c:forEach items="${appellations}" var="appellation">
                                    <option value="${appellation.id}">${appellation.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job">
                        </div>
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone">
                        </div>
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone">
                        </div>
                        <label for="edit-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-status">
                                <option selected></option>
                                <c:forEach items="${states}" var="state">
                                    <option value="${state.id}">${state.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option selected></option>
                                <c:forEach items="${sources}" var="source">
                                    <option value="${source.id}">${source.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
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
                <button type="button" class="btn btn-primary" id="saveEditClueBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>线索列表</h3>
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
                        <input class="form-control" type="text" id="queryByFullName">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司</div>
                        <input class="form-control" type="text" id="queryByCompany">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="queryByPhone">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">手机</div>
                        <input class="form-control" type="text" id="queryByMphone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="queryByOwner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索来源</div>
                        <select class="form-control" id="queryBySource">
                            <option selected></option>
                            <c:forEach items="${sources}" var="source">
                                <option value="${source.id}">${source.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索状态</div>
                        <select class="form-control" id="queryByState">
                            <option selected></option>
                            <c:forEach items="${states}" var="state">
                                <option value="${state.id}">${state.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryClueByConditionBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createClueBtn"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" data-target="#editClueModal" id="editClueBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteClueBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 50px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>公司</td>
                    <td>公司座机</td>
                    <td>手机</td>
                    <td>所有者</td>
                    <td>线索来源</td>
                    <td>线索状态</td>
                </tr>
                </thead>
                <tbody id="clueList"></tbody>
            </table>
            <div id="page"></div>
        </div>
    </div>

</div>
</body>
</html>