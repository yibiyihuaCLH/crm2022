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
    <script type="text/javascript">

        $(function () {

            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation()
            })

            //设置“创建客户”和“修改客户”中“下次联系时间”最早从当天选择
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

            //页面加载完，发送ajax请求获取第一页前十条市场活动数据
            queryCustomerByConditionForPage(1, 10)

            //给"全选"按钮添加单击事件
            $("#checkAll").click(function () {
                $("#customerList input[type='checkbox']").prop("checked", this.checked)
            })
            $("#customerList").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#customerList input[type='checkbox']").size() == $("#customerList input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {//如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给条件“查询”按钮绑定单击事件
            $("#queryCustomer").click(function () {
                queryCustomerByConditionForPage(1, $("#rows_per_page_page").val())
            })

            //根据查询条件分页查询（方法）
            function queryCustomerByConditionForPage(pageNo, pageSize) {
                var name = $.trim($("#query-name").val())
                var owner = $.trim($("#query-owner").val())
                var phone = $.trim($("#query-phone").val())
                var website = $.trim($("#query-website").val())
                $.ajax({
                    url: "workbench/customer/queryCustomerByConditionForPage",
                    data: {
                        name: name,
                        owner: owner,
                        phone: phone,
                        website: website,
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
                        var customers = data.customerList
                        for (let i = 0; i < customers.length; i++) {
                            var customer = customers[i]
                            var id = customer.id
                            var name = customer.name
                            var owner = customer.owner
                            var phone = customer.phone == null||customer.phone == "" ? "未知":customer.phone
                            var website = customer.website == null||customer.phone == "" ? "未知":customer.website

                            html +="<tr>"
                            html +="<td><input type=\"checkbox\" value=\""+ id +"\"/></td>"
                            html +="<td><a style=\"text-decoration: none; cursor: pointer;\""
                            html +="onclick=\"window.location.href='workbench/customer/queryCustomerForDetail.do?id="+ id +"';\">"+ name +"</a></td>"
                            html +="<td>"+ owner +"</td>"
                            html +="<td>"+ phone +"</td>"
                            html +="<td>"+ website +"</td>"
                            html +="</tr>"
                        }
                        $("#customerList").html(html)

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
                                queryCustomerByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            }
                        })
                    }
                })
            }

            //给“创建”按钮添加单击事件
            $("#createCustomerBtn").click(function () {
                $("#create-customerOwner  option[value='${sessionScope.sessionUser.id}'] ").attr("selected",true)
                //弹出创建客户的模态窗口
                $("#createCustomerModal").modal("show")
            })

            //给“保存”按钮绑定单击事件
            $("#saveCreateCustomerBtn").click(function () {
                var owner = $("#create-customerOwner").val()
                var name = $.trim($("#create-customerName").val())
                var website = $.trim($("#create-website").val())
                var phone = $.trim($("#create-phone").val())
                var description = $.trim($("#create-describe").val())
                var contactSummary = $.trim($("#create-contactSummary").val())
                var nextContactTime = $("#create-nextContactTime").val()
                var address = $.trim($("#create-address").val())
                //拦截非法输入
                if (name == null || name == "") {
                    alert("名称不能为空！")
                }
                if (website != null && website != "") {
                    var regExp = /^http:\/\/([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$/
                    if (regExp.test(website)) {
                        alert("输入公司网站不合法！")
                    }
                }
                if (phone != null && phone != "") {
                    var regExp = /0\d{2,3}-\d{7,8}|\(?0\d{2,3}[)-]?\d{7,8}|\(?0\d{2,3}[)-]*\d{7,8}/
                    if (!regExp.test(phone)) {
                        alert("输入公司座机号码不合法！")
                        return
                    }
                }
                $.ajax({
                    url:"workbench/customer/saveCreateCustomer",
                    data:{
                        owner:owner,
                        name:name,
                        website:website,
                        phone:phone,
                        description:description,
                        contactSummary:contactSummary,
                        nextContactTime:nextContactTime,
                        address:address
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if (data.code == "1") {
                            queryCustomerByConditionForPage(1, $("#rows_per_page_page").val())
                            alert(data.message)
                            //隐藏模态窗口
                            $("#createCustomerModal").modal("hide")
                            //重置创建表单
                            $("#createCustomerForm").get(0).reset()
                        }else {
                            alert(data.message)
                        }
                    }
                })
            })

            //给“修改”按钮绑定单击事件
            $("#editCustomerBtn").click(function () {
                var checkedIds = $("#customerList input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("请选择客户")
                    return
                }
                if (checkedIds.length > 1) {
                    alert("最多选择一位客户")
                    return
                }
                //获取选中的复选框id值
                var id = checkedIds[0].value
                $.ajax({
                    url:"workbench/customer/queryEditCustomer",
                    data:{
                        id:id
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        var owner = data.owner
                        var name = data.name
                        var website = data.website
                        var phone = data.phone
                        var description = data.description
                        var contactSummary = data.contactSummary
                        var nextContactTime = data.nextContactTime
                        var address = data.address
                        //判断所有者是否存在（账号未锁定）
                        var ownerValue
                        if (isExistOption("edit-customerOwner", owner)) {
                            $("#edit-customerOwner option[value=lockState]").text("")
                            ownerValue = owner
                        }else {
                            //添加一条错误信息选项
                            $("#edit-customerOwner option[value=lockState]").text("当前客户记录所有者账号已锁定")
                            ownerValue = "lockState"
                        }
                        //初始化选中的客户记录，填写修改的模态窗口表单
                        $("#edit-customerOwner").val(ownerValue)
                        $("#edit-customerName").val(name)
                        $("#edit-website").val(website)
                        $("#edit-phone").val(phone)
                        $("#edit-describe").val(description)
                        $("#edit-contactSummary").val(contactSummary)
                        $("#edit-nextContactTime").val(nextContactTime)
                        $("#edit-address").val(address)
                        //打开“修改”客户模态窗口
                        $("#editCustomerModal").modal("show")
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

            //给修改模态窗口中“更新”按钮绑定单击事件
            $("#saveEditCustomerBtn").click(function () {
                //拦截非法所有者输入
                if ($("#edit-customerOwner").val() == "lockState") {
                    if ($("#edit-customerOwner option[value=lockState]").text() == "") {
                        alert("所有者不能为空!")
                    } else {
                        alert("请选择其他所有者！")
                    }
                    return
                }
                var checkedIds = $("#customerList input[type='checkbox']:checked")
                var id = checkedIds[0].value
                var owner = $("#edit-customerOwner").val()
                var name = $.trim($("#edit-customerName").val())
                var website = $.trim($("#edit-website").val())
                var phone = $.trim($("#edit-phone").val())
                var description = $.trim($("#edit-describe").val())
                var contactSummary = $.trim($("#edit-contactSummary").val())
                var nextContactTime = $("#edit-nextContactTime").val()
                var address = $.trim($("#edit-address").val())
                //拦截非法输入
                if (name == null || name == "") {
                    alert("名称不能为空！")
                }
                if (website != null && website != "") {
                    var regExp = /^http:\/\/([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$/
                    if (regExp.test(website)) {
                        alert("输入公司网站不合法！")
                    }
                }
                if (phone != null && phone != "") {
                    var regExp = /0\d{2,3}-\d{7,8}|\(?0\d{2,3}[)-]?\d{7,8}|\(?0\d{2,3}[)-]*\d{7,8}/
                    if (!regExp.test(phone)) {
                        alert("输入公司座机号码不合法！")
                        return
                    }
                }
                //发送ajax保存修改
                $.ajax({
                    url: "workbench/customer/saveEditCustomer",
                    data: {
                        id:id,
                        owner:owner,
                        name:name,
                        website:website,
                        phone:phone,
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
                            queryCustomerByConditionForPage($("#page").bs_pagination("getOption", "currentPage"), $("#rows_per_page_page").val())
                            //清空全选框
                            $("#checkAll").prop("checked", false)
                            // 关闭模态窗口
                            $("#editCustomerModal").modal("hide")
                        }
                        alert(data.message)
                    }
                })
            })

            //给“删除”按钮绑定单击事件
            $("#deleteCustomerBtn").click(function () {
                var checkedIds = $("#customerList input[type='checkbox']:checked")
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
                        url: "workbench/customer/deleteCustomer",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,刷新市场活动列表
                                queryCustomerByConditionForPage(1, $("#rows_per_page_page").val())
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

<!-- 创建客户的模态窗口 -->
<div class="modal fade" id="createCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createCustomerForm">

                    <div class="form-group">
                        <label for="create-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-customerOwner">
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-customerName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                    </div>
                    <div class="form-group">
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
                <button type="button" class="btn btn-primary" id="saveCreateCustomerBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改客户的模态窗口 -->
<div class="modal fade" id="editCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-customerOwner">
                                <option value="lockState"></option>
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-customerName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone">
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
                <button type="button" class="btn btn-primary" id="saveEditCustomerBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>客户列表</h3>
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
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="query-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="query-phone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司网站</div>
                        <input class="form-control" type="text" id="query-website">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryCustomer">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createCustomerBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editCustomerBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteCustomerBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>公司座机</td>
                    <td>公司网站</td>
                </tr>
                </thead>
                <tbody id="customerList"></tbody>
            </table>
            <div id="page"></div>
        </div>
    </div>

</div>
</body>
</html>