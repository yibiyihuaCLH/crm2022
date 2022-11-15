package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.bean.TransactionHistory;
import com.yibiyihua.crm.workbench.bean.TransactionRemark;
import com.yibiyihua.crm.workbench.service.TransactionHistoryService;
import com.yibiyihua.crm.workbench.service.TransactionRemarkService;
import com.yibiyihua.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/22 15:22
 * @description：交易详情控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/transaction")
@Controller
public class TransactionDetailController {
    @Autowired
    private TransactionService transactionService;
    @Autowired
    private DictionaryValueService dictionaryValueService;
    @Autowired
    private TransactionRemarkService transactionRemarkService;
    @Autowired
    private TransactionHistoryService transactionHistoryService;

    /**
     * 查询交易详细信息
     * @param tranId
     * @return
     */
    @RequestMapping("/queryTransactionForDetail.do")
    public String queryTransactionForDetail(String tranId, HttpServletRequest request) {
        //根据id查询交易详细信息
        Transaction transaction = transactionService.queryTransactionForDetailById(tranId);
        //获取交易可能性
        ResourceBundle tranBundle = ResourceBundle.getBundle("possibility");
        String tranPossibility = tranBundle.getString(transaction.getStage());
        //根据交易id查询交易备注
        List<TransactionRemark> transactionRemarkList = transactionRemarkService.queryRemarkByTransactionId(tranId);
        //根据交易id查询交易阶段历史
        List<TransactionHistory> transactionHistories = transactionHistoryService.queryHistoryByTransactionId(tranId);
        List<Map<String,Object>> transactionHistoryList = new ArrayList<>();
        for (TransactionHistory history:transactionHistories) {
            ResourceBundle historyBundle = ResourceBundle.getBundle("possibility");
            String historyPossibility = historyBundle.getString(history.getStage());
            Map<String,Object> map = new HashMap<>();
            map.put("stage",history.getStage());
            map.put("money",history.getMoney());
            map.put("expectedDate",history.getExpectedDate());
            map.put("createTime",history.getCreateTime());
            map.put("createBy",history.getCreateBy());
            map.put("tranId",history.getTranId());
            map.put("possibility",historyPossibility);
            transactionHistoryList.add(map);
        }
        //查询阶段
        List<DictionaryValue> stageList = dictionaryValueService.queryDictionaryValueByTypeCode("stage");
        //查询当前交易阶段
        DictionaryValue localStage = dictionaryValueService.queryDictionaryByValueAndTypeCode(transaction.getStage(),"stage");
        request.setAttribute("tran",transaction);
        request.setAttribute("possibility",tranPossibility);
        request.setAttribute("tranRemarkList",transactionRemarkList);
        request.setAttribute("tranHistoryList",transactionHistoryList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("localStage",localStage);
        //携带数据跳转至交易详情页面
        return "workbench/transaction/detail";
    }

    /**
     * 保存创建的交易备注
     * @param transactionRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateTransactionRemark")
    @ResponseBody
    public Object saveCreateTransactionRemark(TransactionRemark transactionRemark, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装备注信息
        transactionRemark.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        transactionRemark.setCreateBy(sessionUser.getId());
        transactionRemark.setCreateTime(DateUtil.parseDateToStr(new Date()));
        transactionRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_NO);
        try {
            //保存创建的交易备注
            int result = transactionRemarkService.saveCreateTransactionRemark(transactionRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(transactionRemark);
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

    /**
     * 删除交易备注
     * @param id
     * @return
     */
    @RequestMapping("/deleteTransactionRemark")
    @ResponseBody
    public Object deleteTransactionRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id删除交易备注
            int result = transactionRemarkService.deleteTransactionRemarkById(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 保存编辑的交易备注内容
     * @param transactionRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveEditTransactionRemark")
    @ResponseBody
    public Object saveEditTransactionRemark(TransactionRemark transactionRemark,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装交易备注信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        transactionRemark.setEditBy(sessionUser.getId());
        transactionRemark.setEditTime(DateUtil.parseDateToStr(new Date()));
        transactionRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_YES);
        //根据id保存编辑的文本内容
        int result = transactionRemarkService.saveEditTransactionRemarkById(transactionRemark);
        if (result > 0) {
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setObj(transactionRemark);
            returnObject.setMessage("修改成功！");
        }else {
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 保存交易历史
     * @param tranHistory
     * @param stageName
     * @param session
     * @return
     */
    @RequestMapping("/saveTransactionHistory")
    @ResponseBody
    public Object saveCreateTransactionHistory(TransactionHistory tranHistory,String stageName,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装交易历史信息
        tranHistory.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        tranHistory.setCreateBy(sessionUser.getId());
        tranHistory.setCreateTime(DateUtil.parseDateToStr(new Date()));
        //封装交易信息
        Transaction transaction = new Transaction();
        transaction.setId(tranHistory.getTranId());
        transaction.setStage(tranHistory.getStage());
        transaction.setEditBy(sessionUser.getId());
        transaction.setEditTime(DateUtil.parseDateToStr(new Date()));
        try {
            //保存创建的交易历史
            int result = transactionHistoryService.saveCreateTransactionHistory(tranHistory,transaction);
            if (result > 0) {
                //封装返回参数
                Map<String,Object> map = new HashMap<>();
                map.put("hisCreateBy",sessionUser.getName());
                map.put("hisCreateTime",tranHistory.getCreateTime());
                map.put("tranEditBy",sessionUser.getName());
                map.put("tranEditTime",transaction.getEditTime());
                ResourceBundle bundle = ResourceBundle.getBundle("possibility");
                String possibility = bundle.getString(stageName);
                map.put("possibility",possibility);
                //查询阶段
                List<DictionaryValue> stageList = dictionaryValueService.queryDictionaryValueByTypeCode("stage");
                //查询当前交易阶段
                DictionaryValue localStage = dictionaryValueService.queryDictionaryByValueAndTypeCode(stageName,"stage");
                map.put("stageList",stageList);
                map.put("localStage",localStage);
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(map);
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
