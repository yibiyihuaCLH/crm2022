package com.yibiyihua.crm.settings.mapper;

import com.yibiyihua.crm.settings.bean.User;

import java.util.List;
import java.util.Map;

public interface UserMapper {
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