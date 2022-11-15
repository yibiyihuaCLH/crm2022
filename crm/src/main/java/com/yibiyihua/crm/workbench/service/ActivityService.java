package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Activity;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/26 13:47
 * @description：市场活动业务逻辑层代理接口
 * @modified By：
 * @version: 1.0
 */
public interface ActivityService {

    /**
     * 添加市场价记录
     * @param activity
     * @return
     */
    int saveCreateActivity(Activity activity);

    /**
     * 根据查询条件分页查询市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivityByConditionForPage(Map<String,Object> map);

    /**
     * 根据查询条件查询市场活动记录条数
     * @param map
     * @return
     */
    int queryCountByCondition(Map<String,Object> map);

    /**
     * 根据ids批量删除市场活动
     * @param ids
     * @return
     */
    int deleteActivityByIds(String[] ids) throws Exception;

    /**
     * 根据id查询市场活动记录
     * @param id
     * @return
     */
    Activity queryActivityById(String id);

    /**
     * 保存编辑市场活动记录
     * @param activity
     * @return
     */
    int saveEditActivity(Activity activity);

    /**
     * 查询所有市场活动
     * @return
     */
    List<Activity> queryAllActivity();

    /**
     * 根据ids查询市场活动
     * @param ids
     * @return
     */
    List<Activity> queryActivityByIds(String[] ids);

    /**
     * 根据activityList导入市场活动
     * @param activityList
     * @return
     */
    int addActivityByList(List<Activity> activityList);

    /**
     * 根据id查询市场活动详细信息
     * @param id
     * @return
     */
    Activity queryActivityForDetailById(String id);

    /**
     * 根据线索id查询相关联的市场活动
     * @param clueId
     * @return
     */
    List<Activity> queryActivityByClueId(String clueId);

    /**
     * 根据名称模糊查询未关联当前线索的市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivityByNameWithoutRelation(Map<String,Object> map);

    /**
     * 根据名称模糊查询线索所关联的市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivityByNameAndClueId(Map<String,Object> map);

    /**
     * 根据联系人id查询联系人关联的市场活动
     * @param contactsId
     * @return
     */
    List<Activity> queryActivityByContactsId(String contactsId);

    /**
     * 根据名称模糊查询市场活动
     * @param name
     * @return
     */
    List<Activity> queryActivityByNameLike(String name);
}
