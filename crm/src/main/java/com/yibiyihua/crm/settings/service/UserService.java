package com.yibiyihua.crm.settings.service;

import com.yibiyihua.crm.settings.bean.User;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/24 10:54
 * @description：User业务逻辑层代理接口
 * @modified By：
 * @version: 1.0
 */
public interface UserService {

    /**
     * 根据账号、密码查询用户
     * @param map
     * @return
     */
    User queryUserByLoginActAndPwd(Map<String, Object> map);

    /**
     * 查询所有用户
     * @return
     */
    List<User> queryAllUsers();
}
