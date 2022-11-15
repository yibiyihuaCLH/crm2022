package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.ExcelUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.Activity;
import com.yibiyihua.crm.workbench.bean.ActivityRemark;
import com.yibiyihua.crm.workbench.service.ActivityRemarkService;
import com.yibiyihua.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/26 10:18
 * @description：市场活动控制器
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/activity")
@Controller
public class ActivityController {
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    /**
     * 跳转“市场活动”页面
     * @param request
     * @return
     */
    @RequestMapping("/index.do")
    public String index(HttpServletRequest request) {
        List<User> users = userService.queryAllUsers();
        //将users放入请求作用域
        request.setAttribute("users", users);
        //携带数据返回“市场活动”页面
        return "workbench/activity/index";
    }

    /**
     * 保存创建市场活动
     * @param activity
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateActivity")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session) {
        //封装参数
        //设置市场活动id
        activity.setId(UUIDUtil.uuidToStr());
        //设置市场活动所有者
        activity.setCreateBy(((User) session.getAttribute(Constants.SESSION_USER)).getId());
        //设置市场活动创建时间
        String nowTime = DateUtil.parseDateToStr(new Date());
        activity.setCreateTime(nowTime);
        //保存市场活动
        ReturnObject returnObject = new ReturnObject();
        //返回响应数据
        try {
            //保存创建市场活动
            int result = activityService.saveCreateActivity(activity);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("创建成功！");
            } else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 根据查询条件分页查询市场活动
     * 根据查询条件查询市场活动记录条数
     * @param activity
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/queryActivityByConditionForPageAndQueryCountByCondition")
    @ResponseBody
    public Object queryActivityByConditionForPageAndQueryCountByCondition(
            Activity activity,
            int pageNo,
            int pageSize) {
        //对前端数据封装
        String name = activity.getName();
        String owner = activity.getOwner();
        String startDate = activity.getStartDate();
        String endDate = activity.getEndDate();
        int beginNo = (pageNo-1)*pageSize;
        HashMap<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("beginNo",beginNo);
        map.put("pageSize",pageSize);
        //获取市场活动记录和总记录条数
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryCountByCondition(map);
        //封装市场活动记录和总记录条数
        HashMap<String, Object> returnMap = new HashMap<>();
        returnMap.put("activityList",activityList);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    /**
     * 批量删除市场活动
     * @param id
     * @return
     */
    @RequestMapping("/deleteActivity")
    @ResponseBody
    public Object deleteActivity(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据ids删除市场活动
            int count = activityService.deleteActivityByIds(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("成功删除" + count + "条记录!");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 查询市场活动记录
     * @param id
     * @return
     */
    @RequestMapping("/queryActivity")
    @ResponseBody
    public Activity queryActivityById(String id) {
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    /**
     * 保存编辑市场活动记录
     * @param activity
     * @return
     */
    @RequestMapping("/saveEditActivity")
    @ResponseBody
    public Object saveEditActivity(Activity activity,HttpSession session) {
        //设置编辑时间、编辑人
        activity.setEditTime(DateUtil.parseDateToStr(new Date()));
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        activity.setEditBy(sessionUser.getId());
        ReturnObject returnObject = new ReturnObject();
        //保存编辑
        try {
            int i = activityService.saveEditActivity(activity);
            if (i > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("修改成功！");
            }else {
                returnObject.setMessage(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setMessage(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 批量导出市场活动（excel文件）
     * @param response
     */
    @RequestMapping("/exportAllActivity.do")
    public void exportAllActivity(HttpServletResponse response) throws IOException {
        List<Activity> activityList = activityService.queryAllActivity();
        exportActivity(response,activityList,"市场活动记录（批量）");
    }

    /**
     * 有选择地导出市场活动（excel文件）
     * @param id
     * @param response
     * @throws IOException
     */
    @RequestMapping("/exportActivitySelective.do")
    public void exportActivitySelective(String[] id,HttpServletResponse response) throws IOException {
        List<Activity> activityList = activityService.queryActivityByIds(id);
        exportActivity(response,activityList,"市场活动记录（选择）");
    }

    /**
     * 导出市场活动（私有方法）
     * @param response
     * @param activityList
     * @param activityExcelName
     * @throws IOException
     */
    private void exportActivity(HttpServletResponse response,List<Activity> activityList,String activityExcelName) throws IOException {
        //设置市场活动列名
        HSSFWorkbook excel = new HSSFWorkbook();
        HSSFSheet sheet = excel.createSheet();
        List<String> ActivityColumnName = new ArrayList();
        ActivityColumnName.add("owner");
        ActivityColumnName.add("name");
        ActivityColumnName.add("start_date");
        ActivityColumnName.add("end_date");
        ActivityColumnName.add("cost");
        ActivityColumnName.add("description");
        ActivityColumnName.add("create_time");
        ActivityColumnName.add("create_by");
        ActivityColumnName.add("edit_time");
        ActivityColumnName.add("edit_by");
        ExcelUtil.setColumnName(sheet,ActivityColumnName);
        //将市场活动导入excel类中
        for (int i = 0; i < activityList.size(); i++) {
            //获取市场活动记录
            Activity activity = activityList.get(i);
            List<String> activities = new ArrayList<>();
            activities.add(activity.getOwner());
            activities.add(activity.getName());
            activities.add(activity.getStartDate());
            activities.add(activity.getEndDate());
            activities.add(activity.getCost());
            activities.add(activity.getDescription());
            activities.add(activity.getCreateTime());
            activities.add(activity.getCreateBy());
            activities.add(activity.getEditTime());
            activities.add(activity.getEditBy());
            //将市场活动记录导入i+1行
            ExcelUtil.createCellOnRow(sheet,i+1,activities);
        }
        //将市场活动发送到浏览器
        ExcelUtil.sendExcel(excel,activityExcelName,response);
    }

    /**
     * 下载市场活动导入模板
     * @param response
     * @throws IOException
     */
    @RequestMapping("/downloadTemplate.do")
    public void downloadTemplate(HttpServletResponse response) throws IOException {
        //创建excel对象
        HSSFWorkbook excel = new HSSFWorkbook();
        //创建页
        HSSFSheet sheet = excel.createSheet();
        //创建列名
        List<String> activityColumnName = new ArrayList();
        activityColumnName.add("name");
        activityColumnName.add("start_date");
        activityColumnName.add("end_date");
        activityColumnName.add("cost");
        activityColumnName.add("description");
        ExcelUtil.createCellOnRow(sheet,0,activityColumnName);
        //创建数据模板
        List activityDataExample = new ArrayList();
        activityDataExample.add("发传单");
        activityDataExample.add("2000-01-01");
        activityDataExample.add("2000-01-02");
        activityDataExample.add("1000");
        activityDataExample.add("hello world!");
        ExcelUtil.createCellOnRow(sheet,1,activityDataExample);
        //将
        ExcelUtil.sendExcel(excel,"导入市场活动（模板）",response);
    }

    /**
     * 导入市场活动
     * @param activityFile
     * @return
     */
    @RequestMapping("/importActivity")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        int addCount = 0;
        try {
            //将activityFile数据用HSSFWorkbook进行封装
            InputStream in = activityFile.getInputStream();
            HSSFWorkbook excel = new HSSFWorkbook(in);
            HSSFSheet activitySheet = excel.getSheetAt(0);
            List<Activity> activityList = new ArrayList<>();
            User user = (User) session.getAttribute(Constants.SESSION_USER);
            for (int i = 1; i <= activitySheet.getLastRowNum(); i++) {
                //获取行
                HSSFRow row = activitySheet.getRow(i);
                //封装参数
                Activity activity = new Activity();
                activity.setId(UUIDUtil.uuidToStr());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtil.parseDateToStr(new Date()));
                activity.setCreateBy(user.getId());
                activity.setName(ExcelUtil.getCellValue(row.getCell(0)));
                activity.setStartDate(ExcelUtil.getCellValue(row.getCell(1)));
                activity.setEndDate(ExcelUtil.getCellValue(row.getCell(2)));
                activity.setCost(ExcelUtil.getCellValue(row.getCell(3)));
                activity.setDescription(ExcelUtil.getCellValue(row.getCell(4)));
                //将市场活动添加至List集合
                activityList.add(activity);
            }
            //导入市场活动
            addCount = activityService.addActivityByList(activityList);
            if (addCount > -1) {
                //导入成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("导入成功！成功导入"+ addCount +"条市场活动");
            }else {
                //导入失败
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setCode("系统繁忙，请重试....");
            }
        } catch (IOException e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....（已导入"+ addCount +"条市场活动）");
        }
        return returnObject;
    }
}