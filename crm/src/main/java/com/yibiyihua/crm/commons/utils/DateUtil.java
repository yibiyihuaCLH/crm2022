package com.yibiyihua.crm.commons.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/24 19:52
 * @description：日期工具类
 * @modified By：
 * @version: 1.0
 */
public class DateUtil {
    private static SimpleDateFormat sdf;

    /**
     *将”yyyy-MM-dd HH:mm:ss“格式字符串日期转化为毫秒数
     * @param date
     * @return
     * @throws ParseException
     */
    public static long DateStrToLong(String date) throws ParseException {
        sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.parse(date).getTime();
    }

    /**
     * 将date装换成“yyyy-MM-dd HH:mm:ss”格式字符串日期
     * @param date
     * @return
     */
    public static String parseDateToStr(Date date) {
        sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(date);
    }
}
