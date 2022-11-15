package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.TransactionRemark;
import com.yibiyihua.crm.workbench.mapper.TransactionRemarkMapper;
import com.yibiyihua.crm.workbench.service.TransactionRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/22 15:48
 * @description：交易备注业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class TransactionRemarkServiceImpl implements TransactionRemarkService {
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;

    /**
     * 根据交易id查询交易备注
     * @param tranId
     * @return
     */
    @Override
    public List<TransactionRemark> queryRemarkByTransactionId(String tranId) {
        return transactionRemarkMapper.selectRemarkByTransactionId(tranId);
    }

    /**
     * 保存创建的交易备注
     * @param transactionRemark
     * @return
     */
    @Override
    public int saveCreateTransactionRemark(TransactionRemark transactionRemark) {
        return transactionRemarkMapper.insertTransactionRemark(transactionRemark);
    }

    /**
     * 根据id删除交易备注
     * @param id
     * @return
     */
    @Override
    public int deleteTransactionRemarkById(String id) {
        return transactionRemarkMapper.deleteTransactionRemarkById(id);
    }

    /**
     * 根据id保存编辑的文本内容
     * @param transactionRemark
     * @return
     */
    @Override
    public int saveEditTransactionRemarkById(TransactionRemark transactionRemark) {
        return transactionRemarkMapper.updateTransactionRemarkById(transactionRemark);
    }
}
