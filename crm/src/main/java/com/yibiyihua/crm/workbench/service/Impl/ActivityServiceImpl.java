package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.Activity;
import com.yibiyihua.crm.workbench.mapper.ActivityMapper;
import com.yibiyihua.crm.workbench.mapper.ActivityRemarkMapper;
import com.yibiyihua.crm.workbench.mapper.ClueActivityRelationMapper;
import com.yibiyihua.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.yibiyihua.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/26 13:49
 * @description：市场活动业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    private ActivityMapper activityMapper;
    @Autowired
    private ActivityRemarkMapper activityRemarkMapper;
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    /**
     * 添加市场活动记录
     * @param activity
     * @return
     */
    @Override
    public int saveCreateActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    /**
     * 根据查询条件分页查询市场活动
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByConditionForPage(Map<String, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    /**
     * 根据查询条件查询市场活动记录条数
     * @param map
     * @return
     */
    @Override
    public int queryCountByCondition(Map<String, Object> map) {
        return activityMapper.selectCountByCondition(map);
    }

    /**
     * 根据ids批量删除市场活动
     * @param ids
     * @return
     */
    @Override
    public int  deleteActivityByIds(String[] ids) throws Exception {
        //删除市场活动
        int count = activityMapper.deleteActivityByIds(ids);
        if (count != ids.length) {
            throw new Exception();
        }
        //删除市场活动备注
        activityRemarkMapper.deleteActivityRemarkByActivityIds(ids);
        //删除线索、市场活动关联关系
        clueActivityRelationMapper.deleteRelationshipByActivityIds(ids);
        //删除联系人、市场活动关联关系
        contactsActivityRelationMapper.deleteRelationshipByActivityIds(ids);
        return count;
    }


    /**
     * 根据id查询市场活动记录
     * @param id
     * @return
     */
    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    /**
     * 保存编辑市场活动记录
     * @param activity
     * @return
     */
    @Override
    public int saveEditActivity(Activity activity) {
        return activityMapper.updateActivity(activity);
    }

    /**
     * 查询所有市场活动
     * @return
     */
    @Override
    public List<Activity> queryAllActivity() {
        return activityMapper.selectAllActivity();
    }

    /**
     * 根据ids查询市场活动
     * @param ids
     * @return
     */
    @Override
    public List<Activity> queryActivityByIds(String[] ids) {
        return activityMapper.selectActivityByIds(ids);
    }

    /**
     * 根据activityList导入市场活动
     * @param activityList
     * @return
     */
    @Override
    public int addActivityByList(List<Activity> activityList) {
        return activityMapper.insertActivityByList(activityList);
    }

    /**
     * 根据id查询市场活动详细信息
     * @param id
     * @return
     */
    @Override
    public Activity queryActivityForDetailById(String id) {
        return activityMapper.selectActivityForDetailById(id);
    }

    /**
     * 根据线索id查询相关联的市场活动
     * @param clueId
     * @return
     */
    @Override
    public List<Activity> queryActivityByClueId(String clueId) {
        return activityMapper.selectActivityByClueId(clueId);
    }

    /**
     * 根据名称模糊查询未关联当前线索的市场活动
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByNameWithoutRelation(Map<String, Object> map) {
        return activityMapper.selectActivityByNameWithoutRelation(map);
    }

    /**
     * 根据名称模糊查询线索所关联的市场活动
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByNameAndClueId(Map<String, Object> map) {
        return activityMapper.selectActivityByNameAndClueId(map);
    }

    /**
     * 根据联系人id查询联系人关联的市场活动
     * @param contactsId
     * @return
     */
    @Override
    public List<Activity> queryActivityByContactsId(String contactsId) {
        return activityMapper.selectActivityByContactsId(contactsId);
    }

    /**
     * 根据名称模糊查询市场活动
     * @param name
     * @return
     */
    @Override
    public List<Activity> queryActivityByNameLike(String name) {
        return activityMapper.selectActivityByNameLike(name);
    }


}
