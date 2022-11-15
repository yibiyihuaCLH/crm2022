package com.yibiyihua.crm.settings.service.Impl;

import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.mapper.UserMapper;
import com.yibiyihua.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/24 10:56
 * @description：User业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    UserMapper userMapper;

    /**
     * 根据账号、密码查询用户
     * @param map
     * @return
     */
    @Override
    public User queryUserByLoginActAndPwd(Map<String, Object> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    /**
     * 查询所有用户
     * @return
     */
    @Override
    public List<User> queryAllUsers() {
        return userMapper.selectAllUsers();
    }
}
