package record.wilson.flutter.com.flutter_plugin_record_329.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

public class DateUtils {
    public static String dateToString(Date date) {
        String str = "yyyyMMddhhmmss";
        SimpleDateFormat format = new SimpleDateFormat(str);
        String dateFormat = format.format(date);
        return dateFormat;
    }
}
