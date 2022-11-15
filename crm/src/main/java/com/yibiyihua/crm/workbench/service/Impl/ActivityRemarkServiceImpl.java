package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.Activity;
import com.yibiyihua.crm.workbench.bean.ActivityRemark;
import com.yibiyihua.crm.workbench.mapper.ActivityRemarkMapper;
import com.yibiyihua.crm.workbench.service.ActivityRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/10 9:54
 * @description：市场活动备注业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ActivityRemarkServiceImpl implements ActivityRemarkService {

    @Autowired
    private ActivityRemarkMapper activityRemarkMapper;

    /**
     * 根据市场活动id查询市场活动备注
     * @return
     */
    @Override
    public List<ActivityRemark> queryActivityRemarkForDetailByActivityId(String activityId) {
        return activityRemarkMapper.selectActivityRemarkForDetailByActivityId(activityId);
    }

    /**
     * 添加市场活动备注
     * @param activityRemark
     * @return
     */
    @Override
    public int addActivityRemark(ActivityRemark activityRemark) {
        return activityRemarkMapper.insertActivityRemark(activityRemark);
    }

    /**
     * 根据id删除市场互动备注
     * @param id
     * @return
     */
    @Override
    public int deleteActivityRemarkById(String id) {
        return activityRemarkMapper.deleteActivityRemarkById(id);
    }

    /**
     * 根据id修改市场活动备注
     * @param activityRemark
     * @return
     */
    @Override
    public int editActivityRemarkById(ActivityRemark activityRemark) {
        return activityRemarkMapper.updateActivityRemarkById(activityRemark);
    }

    /**
     * 根据id查询市场活动备注
     * @param id
     * @return
     */
    @Override
    public ActivityRemark queryActivityRemarkById(String id) {
        return activityRemarkMapper.selectActivityRemarkById(id);
    }
}
