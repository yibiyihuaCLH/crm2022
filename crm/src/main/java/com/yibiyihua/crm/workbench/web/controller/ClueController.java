package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.Clue;
import com.yibiyihua.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/12 15:08
 * @description：线索控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/clue")
@Controller
public class ClueController {
    @Autowired
    private UserService userService;
    @Autowired
    private DictionaryValueService dictionaryValueService;
    @Autowired
    private ClueService clueService;

    /**
     * 跳转“线索（潜在客户）”页面
     * @param request
     * @return
     */
    @RequestMapping("/index.do")
    public String index(HttpServletRequest request) {
        //查询字典值将其保存request中
        List<User> userList = userService.queryAllUsers();
        List<DictionaryValue> appellationList = dictionaryValueService.queryDictionaryValueByTypeCode("appellation");
        List<DictionaryValue> clueStateList = dictionaryValueService.queryDictionaryValueByTypeCode("clueState");
        List<DictionaryValue> sourceList = dictionaryValueService.queryDictionaryValueByTypeCode("source");
        request.setAttribute("users",userList);
        request.setAttribute("appellations",appellationList);
        request.setAttribute("states",clueStateList);
        request.setAttribute("sources",sourceList);
        //携带数据请求转发至“线索（潜在客户）”页面
        return "workbench/clue/index";
    }

    /**
     * 保存创建线索
     * @param clue
     * @param session
     * @return
     */
    @RequestMapping("/saveAddClue")
    @ResponseBody
    public Object saveAddClue(Clue clue, HttpSession session) {
        //补全线索信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        clue.setId(UUIDUtil.uuidToStr());
        clue.setCreateBy(sessionUser.getId());
        clue.setCreateTime(DateUtil.parseDateToStr(new Date()));
        //生成响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int count = clueService.addClue(clue);
            if (count > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("创建成功！");
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试...");
        }
        return returnObject;
    }

    /**
     * 分页查询线索和查询线索总条数
     * @param clue
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/queryClueByConditionForPageAndTotalRow")
    @ResponseBody
    public Object queryClueByConditionForPageAndTotalRow(
            Clue clue,
            Integer pageNo,
            Integer pageSize) {
        //获取参数
        String fullName = clue.getFullName();
        String company = clue.getCompany();
        String phone = clue.getPhone();
        String source = clue.getSource();
        String owner = clue.getOwner();
        String mphone = clue.getMphone();
        String state = clue.getState();
        Integer beginNo = (pageNo - 1)*pageSize;
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("fullName",fullName);
        map.put("company",company);
        map.put("phone",phone);
        map.put("source",source);
        map.put("owner",owner);
        map.put("mphone",mphone);
        map.put("state",state);
        map.put("beginNo",beginNo);
        map.put("pageSize",pageSize);
        //根据条件有选择地查询线索
        List<Clue> clues = clueService.queryClueByConditionForPage(map);
        //根据条件查询线索总条数
        int totalRows = clueService.queryClueCountByCondition(map);
        //封装返回参数
        Map<String,Object> returnMap = new HashMap<>();
        returnMap.put("clues",clues);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    /**
     * 批量删除线索
     * @param id
     * @return
     */
    @RequestMapping("/deleteClue")
    @ResponseBody
    public Object deleteClue(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            int count = clueService.deleteClueByIds(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("成功删除"+ count +"条记录!");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 查询线索记录
     * @param id
     * @return
     */
    @RequestMapping("/queryClue")
    @ResponseBody
    public Object queryClue(String id) {
        Clue clue = clueService.queryClueById(id);
        return clue;
    }

    /**
     * 保存更新的线索
     * @param clue
     * @param session
     * @return
     */
    @RequestMapping("/saveEditClue")
    @ResponseBody
    public Object saveEditClue(Clue clue,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        try {
            User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
            clue.setEditBy(sessionUser.getId());
            clue.setEditTime(DateUtil.parseDateToStr(new Date()));
            int result = clueService.saveEditClueById(clue);
            if (result >0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("修改成功！");
            }else {
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
}

