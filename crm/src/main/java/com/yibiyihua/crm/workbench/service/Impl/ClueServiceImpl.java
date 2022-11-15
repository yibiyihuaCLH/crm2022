package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.workbench.bean.*;
import com.yibiyihua.crm.workbench.mapper.*;
import com.yibiyihua.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/13 9:35
 * @description：线索业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ClueServiceImpl implements ClueService {
    @Autowired
    private ClueMapper clueMapper;
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private ClueRemarkMapper clueRemarkMapper;
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;

    /**
     * 添加线索
     * @param clue
     * @return
     */
    @Override
    public int addClue(Clue clue) {
        return clueMapper.insertClue(clue);
    }

    /**
     * 根据条件分页查询线索
     * @param map
     * @return
     */
    @Override
    public List<Clue> queryClueByConditionForPage(Map<String, Object> map) {
        return clueMapper.selectClueByConditionForPage(map);
    }

    /**
     * 根据条件查询线索总条数
     * @param map
     * @return
     */
    @Override
    public int queryClueCountByCondition(Map<String, Object> map) {
        return clueMapper.selectClueCountByCondition(map);
    }

    /**
     * 根据ids删除线索
     * @param ids
     * @return
     */
    @Override
    public int deleteClueByIds(String[] ids) throws Exception {
        int count = clueMapper.deleteClueByIds(ids);
        if (count != ids.length) {
            throw new Exception();
        }
        //删除线索备注
        clueRemarkMapper.deleteClueRemarkByClueIds(ids);
        //删除线索、市场活动关联关系
        clueActivityRelationMapper.deleteRelationshipByClueIds(ids);
        return count;
    }

    /**
     * 根据id查询线索
     * @param id
     * @return
     */
    @Override
    public Clue queryClueById(String id) {
        return clueMapper.selectClueById(id);
    }

    /**
     * 根据id保存编辑的线索
     * @param clue
     * @return
     */
    @Override
    public int saveEditClueById(Clue clue) {
        return clueMapper.updateClueById(clue);
    }

    /**
     * 通过id查询线索详细信息
     * @param id
     * @return
     */
    @Override
    public Clue queryClueForDetailById(String id) {
        return clueMapper.selectClueForDetailById(id);
    }

    /**
     * 保存线索转换
     * @param map
     */
    @Override
    public void saveClueConvert(Map<String, Object> map) {
        //获取参数
        String clueId = String.valueOf(map.get("clueId"));
        String sessionUserId = String.valueOf(map.get(Constants.SESSION_USER));
        boolean isCreateTran = (boolean) map.get("isCreateTran");
        Transaction transaction = (Transaction) map.get("transaction");
        //查询此线索全部信息
        Clue clue = clueMapper.selectClueById(clueId);
        //根据客户名称查询客户
        String customerId = customerMapper.selectCustomerIdByName(clue.getCompany());
        if (customerId == null || "".equals(customerId)) {//客户未存在，新建客户
            //1.将线索中有关公司的信息添加到客户表中
            Customer customer = new Customer();
            customer.setId(UUIDUtil.uuidToStr());
            customer.setOwner(sessionUserId);
            customer.setName(clue.getCompany());
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(sessionUserId);
            customer.setCreateTime(DateUtil.parseDateToStr(new Date()));
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            customerMapper.insertCustomer(customer);
            customerId = customer.getId();
        }
        //2.将线索中有关个人的信息添加到联系人表中
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.uuidToStr());
        contacts.setOwner(sessionUserId);
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customerId);
        contacts.setFullName(clue.getFullName());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateBy(sessionUserId);
        contacts.setCreateTime(DateUtil.parseDateToStr(new Date()));
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setAddress(clue.getAddress());
        contactsMapper.insertContacts(contacts);
        //查询此线索的全部备注信息
        List<ClueRemark> clueRemarkList = clueRemarkMapper.selectClueRemarkByClueId(clueId);
        if (clueRemarkList.size() > 0) {//此线索存在备注，进行转移
            //封装客户备注信息
            List<CustomerRemark> customerRemarkList = new ArrayList<>();
            for (int i = 0; i < clueRemarkList.size(); i++) {
                CustomerRemark customerRemark = new CustomerRemark();
                ClueRemark clueRemark = clueRemarkList.get(i);
                customerRemark.setId(UUIDUtil.uuidToStr());
                customerRemark.setNoteContent(clueRemark.getNoteContent());
                customerRemark.setCreateBy(clueRemark.getCreateBy());
                customerRemark.setCreateTime(clueRemark.getCreateTime());
                customerRemark.setEditBy(clueRemark.getEditBy());
                customerRemark.setEditTime(clueRemark.getEditTime());
                customerRemark.setEditFlag(clueRemark.getEditFlag());
                customerRemark.setCustomerId(customerId);
                customerRemarkList.add(customerRemark);
                //3.将封装的客户备注添加到客户备注表中
                customerRemarkMapper.insertCustomerRemarkList(customerRemarkList);
            }
            //封装联系人备注信息
            List<ContactsRemark> contactsRemarkList = new ArrayList<>();
            //封装联系人信息
            for (int i = 0; i < clueRemarkList.size(); i++) {
                ContactsRemark contactsRemark = new ContactsRemark();
                ClueRemark clueRemark = clueRemarkList.get(i);
                contactsRemark.setId(UUIDUtil.uuidToStr());
                contactsRemark.setNoteContent(clueRemark.getNoteContent());
                contactsRemark.setCreateBy(clueRemark.getCreateBy());
                contactsRemark.setCreateTime(clueRemark.getCreateTime());
                contactsRemark.setEditBy(clueRemark.getEditBy());
                contactsRemark.setEditTime(clueRemark.getEditTime());
                contactsRemark.setEditFlag(clueRemark.getEditFlag());
                contactsRemark.setContactsId(contacts.getId());
                contactsRemarkList.add(contactsRemark);
            }
            //4.将线索的备注信息添加到联系人备注表中
            contactsRemarkMapper.insertContactsRemarkByList(contactsRemarkList);
        }
        //查询此线索关联的市场活动记录
        List<String> activityList = clueActivityRelationMapper.selectRelationShipByClueId(clueId);
        //封装线索、市场活动关联关系信息
        if (activityList.size() > 0) {//此线索存在市场活动关联关系，进行转移
            //封装联系人、市场活动关联关系信息
            List<ContactsActivityRelation> contactsActivityRelationList = new ArrayList<>();
            for (int i = 0; i < activityList.size(); i++) {
                String activity = activityList.get(i);
                ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtil.uuidToStr());
                contactsActivityRelation.setContactsId(contacts.getId());
                contactsActivityRelation.setActivityId(activity);
                contactsActivityRelationList.add(contactsActivityRelation);
            }
            //5.将线索和市场活动的关联关系添加到联系人和市场互动的关联关系表中
            contactsActivityRelationMapper.insertRelationByList(contactsActivityRelationList);
        }
        if (isCreateTran) {//此线索需要创建交易，添加交易
            //封装交易信息
            transaction.setId(UUIDUtil.uuidToStr());
            transaction.setOwner(sessionUserId);
            transaction.setCustomerId(customerId);
            transaction.setType("97d1128f70294f0aac49e996ced28c8a");//新业务
            transaction.setContactsId(contacts.getId());
            transaction.setCreateBy(sessionUserId);
            transaction.setCreateTime(DateUtil.parseDateToStr(new Date()));
            transaction.setDescription(clue.getDescription());
            transaction.setContactSummary(clue.getContactSummary());
            transaction.setNextContactTime(clue.getNextContactTime());
            //6.为客户创建交易
            transactionMapper.insertTransaction(transaction);
            if (clueRemarkList.size() > 0) {//此线索存在备注，进行转移
                //封装交易备注信息
                List<TransactionRemark> transactionRemarkList = new ArrayList<>();
                for (int i = 0; i < clueRemarkList.size(); i++) {
                    ClueRemark clueRemark = clueRemarkList.get(i);
                    TransactionRemark transactionRemark = new TransactionRemark();
                    transactionRemark.setId(UUIDUtil.uuidToStr());
                    transactionRemark.setNoteContent(clueRemark.getNoteContent());
                    transactionRemark.setCreateBy(sessionUserId);
                    transactionRemark.setCreateTime(clueRemark.getCreateTime());
                    transactionRemark.setEditBy(clueRemark.getEditBy());
                    transactionRemark.setEditTime(clueRemark.getEditTime());
                    transactionRemark.setEditFlag(clueRemark.getEditFlag());
                    transactionRemark.setTranId(transaction.getId());
                    transactionRemarkList.add(transactionRemark);
                }
                //7.把线索的备注信息转移到交易备注表中
                transactionRemarkMapper.insertTransactionRemarkByList(transactionRemarkList);
            }
        }
        //8.删除线索备注
        if (clueRemarkList.size() > 0){//此线索无备注不操作，提高效率
            clueRemarkMapper.deleteClueRemarkByClueId(clueId);
        }
        //9.删除线索和市场活动关联关系
        if (activityList.size() > 0){
            clueActivityRelationMapper.deleteRelationshipByClueId(clueId);
        }
        //10.删除线索
        clueMapper.deleteClueById(clueId);
    }
}
