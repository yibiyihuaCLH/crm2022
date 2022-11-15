package com.yibiyihua.crm.settings.mapper;

import com.yibiyihua.crm.settings.bean.User;

import java.util.List;
import java.util.Map;

public interface UserMapper {
    /**
     * 按主键查询用户记录
     * @param id
     * @return
     */
    User selectByPrimaryKey(String id);

    /**
     * 按主键删除用户记录
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入记录
     * @param record
     * @return
     */
    int insert(User record);

    /**
     * 选择性插入
     * @param record
     * @return
     */
    int insertSelective(User record);

    /**
     * 按主键选择性更新
     * @param record
     * @return
     */
    int updateByPrimaryKeySelective(User record);

    /**
     * 按主键更新
     * @param record
     * @return
     */
    int updateByPrimaryKey(User record);

    /**
     * 根据账号、密码查询用户
     * @param map
     * @return
     */
    User selectUserByLoginActAndPwd(Map<String, Object> map);

    /**
     * 查询所有用户
     * @return
     */
    List<User> selectAllUsers();
}