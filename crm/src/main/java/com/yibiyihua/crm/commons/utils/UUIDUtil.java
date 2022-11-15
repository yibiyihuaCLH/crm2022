package com.yibiyihua.crm.commons.utils;

import java.util.UUID;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/26 14:11
 * @description：UUID工具类
 * @modified By：
 * @version: 1.0
 */
public class UUIDUtil {

    /**
     * 获取uuid字符串去“-”格式
     * @return
     */
    public static String uuidToStr() {
        return UUID.randomUUID().toString().replaceAll("-","");
    }
}
