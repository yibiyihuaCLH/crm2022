<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">

<html>
<head>
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200)
			}else{
				$("#create-transaction2").hide(200)
			}
		})

		//设置“预计成交时间”最早从当天选择
		selectDateAfterToday("expectedClosingDate")
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

		//给查询“市场活动源”链接绑定单击事件
		$("#queryRelationActivityBtn").click(function () {
			$("#fuzzyQuery").val("")
			queryRelationActivity("")
			//弹出“搜索市场活动”模态窗口
			$("#searchActivityModal").modal("show")
		})

		//给“模糊查询”输入框绑定键出事件
		$("#fuzzyQuery").keyup(function () {
			var name = this.value
			queryRelationActivity(name)
		})

		//查询相关联的市场活动（方法）
		function queryRelationActivity(name) {
			var clueId = "${clue.id}"
			$.ajax({
				url:"workbench/clue/queryRelationActivity",
				data:{
					name:name,
					clueId:clueId
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					var html = ""
					for (let i = 0; i < data.length; i++) {
						var activity = data[i]
						var id = activity.id
						var name = activity.name
						var startDate = activity.startDate == "" ? "？":activity.startDate
						var endDate = activity.endDate == "" ? "？":activity.endDate
						var owner = activity.owner
						html += "<tr>"
						html += "<td><input type=\"radio\" name=\"activity\" value=\""+ id +"\" activityName=\""+ name +"\"/></td>"
						html += "<td>"+ name +"</td>"
						html += "<td>"+ startDate +"</td>"
						html += "<td>"+ endDate +"</td>"
						html += "<td>"+ owner +"</td>"
						html += "</tr>"
					}
					$("#activityList").html(html)
				}
			})
		}

		//给所有市场活动选择按钮绑定单击事件
		$("#activityList").on("click","input[name='activity']",function () {
			var activityId = this.value
			var activityName = $(this).attr("activityName")
			$("#activity").val(activityName)
			$("#activity").attr("activityId",activityId)
			//关闭模态窗口
			$("#searchActivityModal").modal("hide")
		})

		//给“转换”按钮绑定单击事件
		$("#ClueConvertBtn").click(function () {
			var clueId = "${clue.id}"
			var isCreateTran = $("#isCreateTransaction").is(":checked")
			var money = $("#amountOfMoney").val()
			var name = $("#tradeName").val()
			var expectedDate = $("#expectedClosingDate").val()
			var stage = $("#stage").val()
			var activityId = $("activity").attr("activityId")
			//拦截非法输入
			if (money != "") {
				var regExp = /^(([1-9]\d*)|0)$/
				if (!regExp.test(money)) {
					alert("成本只能为非负整数")
					return
				}
			}
			if (name == null || name == "") {
				alert("交易名称不能为空！")
				return
			}
			if (expectedDate == null || expectedDate == "") {
				alert("预计成交日期不能为空！")
				return
			}
			if(stage == null || stage == "") {
				alert("请选择阶段！")
				return
			}
			$.ajax({
				url: "workbench/clue/ClueConvert.do",
				data: {
					clueId: clueId,
					isCreateTran:isCreateTran,
					money:money,
					name:name,
					expectedDate:expectedDate,
					stage:stage,
					activityId:activityId
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if (data.code == "1") {
						alert(data.message)
						window.location.href = "workbench/clue/index.do"
					}else {
						alert(data.message)
					}
				}
			})
		})
	})
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询" id="fuzzyQuery">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activityList"></tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${clue.fullName}${clue.appellation}-${clue.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${clue.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${clue.fullName}${clue.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form>
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">
				交易名称
				<span style="font-size: 15px; color: red;">*</span>
			</label>
		    <input type="text" class="form-control" id="tradeName" value="${clue.company}-">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">
				预计成交日期
				<span style="font-size: 15px; color: red;">*</span>
			</label>
		    <input type="date" class="form-control" id="expectedClosingDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">
				阶段
				<span style="font-size: 15px; color: red;">*</span>
			</label>
		    <select id="stage"  class="form-control">
		    	<option></option>
		    	<c:forEach items="${stages}" var="stage">
					<option value="${stage.id}">${stage.value}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" style="text-decoration: none;" id="queryRelationActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activity" activityId="" placeholder="点击“放大镜”搜索" readonly>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${clue.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" value="转换" id="ClueConvertBtn">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>