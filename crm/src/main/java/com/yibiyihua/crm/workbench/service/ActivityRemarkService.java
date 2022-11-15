package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.ActivityRemark;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/10 9:48
 * @description：市场活动备注业务逻辑层代理接口
 * @modified By：
 * @version: 1.0
 */
public interface ActivityRemarkService {

    /**
     * 根据市场活动id查询市场活动备注
     * @return
     */
    public List<ActivityRemark> queryActivityRemarkForDetailByActivityId(String activityId);

    /**
     * 添加市场活动备注
     * @param activityRemark
     * @return
     */
    public int addActivityRemark(ActivityRemark activityRemark);

    /**
     * 根据id删除市场互动备注
     * @param id
     * @return
     */
    int deleteActivityRemarkById(String id);

    /**
     * 根据id修改市场活动备注
     * @param activityRemark
     * @return
     */
    int editActivityRemarkById(ActivityRemark activityRemark);

    /**
     * 根据id查询市场活动备注
     * @param id
     * @return
     */
    ActivityRemark queryActivityRemarkById(String id);
}
