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
            //页面加载完，发送ajax请求获取第一页前十条市场活动数据
            queryActivityByConditionForPage(1, 10)

            //给"全选"按钮添加单击事件
            $("#checkAll").click(function () {
                $("#arrayList input[type='checkbox']").prop("checked", this.checked)
            })
            $("#arrayList").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则"全选"按钮也选中
                if ($("#arrayList input[type='checkbox']").size() == $("#arrayList input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {//如果列表中的所有checkbox至少有一个没选中，则"全选"按钮也取消
                    $("#checkAll").prop("checked", false)
                }
            })

            //给“查询”按钮绑定单击事件
            $("#queryActivityBtn").click(function () {
                queryActivityByConditionForPage(1,$("#rows_per_page_page").val())
            })

            //根据查询条件分页查询（方法）
            function queryActivityByConditionForPage(pageNo, pageSize) {
                var name = $("#query-name").val()
                var owner = $("#query-owner").val()
                var startDate = $("#query-startDate").val()
                var endDate = $("#query-endDate").val()
                $.ajax({
                    url: "workbench/activity/queryActivityByConditionForPageAndQueryCountByCondition",
                    data: {
                        name: name,
                        owner: owner,
                        startDate: startDate,
                        endDate: endDate,
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
                        var activities = data.activityList
                        for (let i = 0; i < activities.length; i++) {
                            var activity = activities[i]
                            var id = activity.id
                            var name = activity.name
                            var owner = activity.owner
                            var startDate = activity.startDate == null ||activity.startDate == "" ? "？":activity.startDate
                            var endDate = activity.endDate == null || activity.endDate == "" ? "？":activity.endDate

                            html += "<tr class=\"active\">"
                            html += "<td><input type=\"checkbox\" name=\"checkOne\" value=\"" + id + "\"/></td>"
                            html += "<td><a style=\"text-decoration: none; cursor: pointer;\" "
                            html += "onclick=\"window.location.href='workbench/activity/queryActivityDetail.do?id=" + id + "'\">" + name + "</a></td>"
                            html += "<td>" + owner + "</td>"
                            html += "<td>" + startDate + "</td>"
                            html += "<td>" + endDate + "</td>"
                            html += "</tr>"
                        }
                        $("#arrayList").html(html)

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
                                queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            }
                        })
                    }
                })
            }

            //给“创建”按钮添加单击事件
            $("#createActivityBtn").click(function () {
                $("#create-marketActivityOwner  option[value='${sessionScope.sessionUser.id}'] ").attr("selected",true)
                //弹出创建市场活动的模态窗口
                $("#createActivityModal").modal("show")
            })

            //给创建市场活动模态窗口“保存”按钮添加单击事件
            $("#saveCreateActivity").click(function () {
                var owner = $("#create-marketActivityOwner").val()
                var name = $.trim($("#create-marketActivityName").val())
                var startDate = $("#create-startTime").val()
                var endDate = $("#create-endTime").val()
                var cost = $.trim($("#create-cost").val())
                var description = $.trim($("#create-describe").val())
                //拦截非法输入
                if (name == "") {
                    alert("名称不能为空")
                    return
                }
                if (startDate != "" && endDate != "") {
                    if (startDate > endDate) {
                        alert("结束日期不能比开始日期小")
                        return
                    }
                }
                if (cost != "") {
                    var regExp = /^(([1-9]\d*)|0)$/
                    if (!regExp.test(cost)) {
                        alert("成本只能为非负整数")
                        return
                    }
                }
                //数据无误，发送ajax请求
                $.ajax({
                    url: "workbench/activity/saveCreateActivity",
                    data: {
                        owner: owner,
                        name: name,
                        startDate: startDate,
                        endDate: endDate,
                        cost: cost,
                        description: description
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            //保存成功，刷新市场活动列表
                            queryActivityByConditionForPage(1, $("#rows_per_page_page").val())
                            alert(data.message)
                            //隐藏模态窗口
                            $("#createActivityModal").modal("hide")
                            //重置创建表单
                            $("#createActivityForm").get(0).reset()
                        } else {
                            //保存失败
                            alert(data.message)
                        }
                    }
                })
            })

            //给“修改”按钮绑定单击事件
            $("#editActivityBtn").click(function () {
                var checkedIds = $("#arrayList input[type='checkbox']:checked")
                if (checkedIds.length == 0) {
                    alert("请选择市场活动")
                    return
                }
                if (checkedIds.length > 1) {
                    alert("最多选择一条市场活动")
                    return
                }
                //获取选中的复选框id值
                var id = checkedIds[0].value
                $.ajax({
                    url: "workbench/activity/queryActivity",
                    data: {
                        id: id
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        var owner = data.owner
                        var name = data.name
                        var startDate = data.startDate
                        var endDate = data.endDate
                        var cost = data.cost
                        var description = data.description
                        //判断所有者是否存在（账号未锁定）
                        var ownerValue
                        if (isExistOption("edit-marketActivityOwner", owner)) {
                            $("#edit-marketActivityOwner option[value=lockState]").text("")
                            ownerValue = owner
                        }else {
                            //添加一条错误信息选项
                            $("#edit-marketActivityOwner option[value=lockState]").text("当前市场活动所有者账号已锁定")
                            ownerValue = "lockState"
                        }
                        //初始化选中的市场活动记录，填写修改的模态窗口表单
                        $("#edit-marketActivityOwner").val(ownerValue)
                        $("#edit-marketActivityName").val(name)
                        $("#edit-startTime").val(startDate)
                        $("#edit-endTime").val(endDate)
                        $("#edit-cost").val(cost)
                        $("#edit-describe").val(description)
                        //弹出修改市场活动的模态窗口
                        $("#editActivityModal").modal("show")
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
            $("#saveEditBtn").click(function () {
                //拦截非法所有者输入
                if ($("#edit-marketActivityOwner").val() == "lockState") {
                    if ($("#edit-marketActivityOwner option[value=lockState]").text() == "") {
                        alert("所有者不能为空!")
                    } else {
                        alert("请选择其他所有者！")
                    }
                    return
                }
                var checkedIds = $("#arrayList input[type='checkbox']:checked")
                var id = checkedIds[0].value
                var owner = $("#edit-marketActivityOwner").val()
                var name = $("#edit-marketActivityName").val()
                var startDate = $("#edit-startTime").val()
                var endDate = $("#edit-endTime").val()
                var cost = $("#edit-cost").val()
                var description = $("#edit-describe").val()
                //拦截非法输入
                if (name == "") {
                    alert("名称不能为空!")
                    return
                }
                if (startDate != "" && endDate != "") {
                    if (startDate > endDate) {
                        alert("结束日期不能比开始日期小!")
                        return
                    }
                }
                if (cost != "") {
                    var regExp = /^(([1-9]\d*)|0)$/
                    if (!regExp.test(cost)) {
                        alert("成本只能为非负整数!")
                        return
                    }
                }
                //发送ajax保存修改
                $.ajax({
                    url: "workbench/activity/saveEditActivity",
                    data: {
                        id: id,
                        owner: owner,
                        name: name,
                        startDate: startDate,
                        endDate: endDate,
                        cost: cost,
                        description: description
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code = "1") {
                            //更新成功，刷新市场活动记录
                            queryActivityByConditionForPage($("#page").bs_pagination("getOption", "currentPage"), $("#rows_per_page_page").val())
                            //清空全选框
                            $("#checkAll").prop("checked", false)
                            // 关闭模态窗口
                            $("#editActivityModal").modal("hide")
                        }
                        alert(data.message)

                    }
                })
            })

            //给“删除”按钮绑定单击事件
            $("#deleteActivityBtn").click(function () {
                var checkedIds = $("#arrayList input[type='checkbox']:checked")
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
                        url: "workbench/activity/deleteActivity",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code == "1") {
                                //删除成功,刷新市场活动列表
                                queryActivityByConditionForPage(1, $("#rows_per_page_page").val())
                                //全选复选框取消选中
                                $("#checkAll").prop("checked", false)
                            }
                            alert(data.message)
                        }
                    })
                }
            })

            //给“下载模板”按钮绑定单击事件
            $("#downloadTemplateBtn").click(function () {
                window.location.href = "workbench/activity/downloadTemplate.do"
            })

            //给“导入”按钮绑定单击事件
            $("#importActivityBtn").click(function () {
                var activityFilePath = $("#activityFile").val()
                //判断文件是否为excel（.xls格式）
                if (activityFilePath.substring(activityFilePath.length - 4).toLocaleLowerCase() != ".xls") {
                    alert("只支持\".xsl\"格式文件")
                    return
                }
                var activityFile = $("#activityFile")[0].files[0]
                //判断文件大小是否超过5MB
                if (activityFile.size > 5 * 1024 * 1024) {
                    alert("文件大小不超过5MB")
                    return
                }
                var formData = new FormData()
                formData.append("activityFile", activityFile)
                $.ajax({
                    url: "workbench/activity/importActivity",
                    type: "post",
                    data: formData,
                    dataType: "json",
                    processData: false,//是否将数据统一转化为字符串，默认true
                    contentType: false,//是否将参数统一按urlencoded（只能对字符串进行编码）编码，默认true
                    success: function (data) {
                        if (data.code == "1") {
                            //导入成功，显示成功导入记录条数
                            alert(data.message)
                            //关闭模态窗口
                            $("#importActivityModal").modal("hide")
                            //刷新市场活动列表，显示第一页数据，保持每页显示条数不变
                            queryActivityByConditionForPage(1, $("#rows_per_page_page").val())
                        } else {
                            //导入失败，提示信息
                            alert(data.message)
                            $("#importActivityModal").modal("show")
                        }
                    }
                })
            })

            //给“下载列表数据（批量导出）”按钮绑定单击事件
            $("#exportActivityAllBtn").click(function () {
                window.location.href = "workbench/activity/exportAllActivity.do"
            })

            //给“下载列表数据（选择导出）”按钮绑定单击事件
            $("#exportActivityXzBtn").click(function () {
                var checkedIds = $("#arrayList input[type='checkbox']:checked")
                //判断导出条数是否为空
                if (checkedIds.length == 0) {
                    alert("至少导出一条市场活动")
                    return
                }
                if (window.confirm("确认是否导出？")) {
                    //拼接data数据
                    var ids = ""
                    for (let i = 0; i < checkedIds.length; i++) {
                        ids += "id=" + checkedIds[i].value + "&"
                    }
                    ids = ids.substring(0, ids.length - 1)
                    window.location.href = "workbench/activity/exportActivitySelective.do?" + ids
                }
            })

        })

    </script>
    <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
</head>
<body>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="createActivityForm">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="create-startTime">
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="create-endTime">
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本/￥</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" id="saveCreateActivity">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <option value="lockState"></option>
                                <c:forEach items="${users}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="edit-startTime">
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="date" class="form-control" id="edit-endTime">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本/￥</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" id="saveEditBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 导入市场活动的模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input type="file" id="activityFile">
                </div>
                <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;">
                    <h3>重要提示</h3>
                    <ul>
                        <li><input type="button" id="downloadTemplateBtn" value="下载模板"></li>
                        <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                        <li>给定文件的第一行将视为字段名。</li>
                        <li>请确认您的文件大小不超过5MB。</li>
                        <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                        <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                        <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                        <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
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
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control" type="date" id="query-startDate"/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control" type="date" id="query-endDate">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createActivityBtn"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editActivityBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal">
                    <span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）
                </button>
                <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）
                </button>
                <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）
                </button>
            </div>
        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="arrayList"></tbody>
            </table>
            <div id="page"></div>
        </div>
    </div>

</div>
</body>
</html>