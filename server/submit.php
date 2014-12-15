<?php
function technicalMailAddress() {
    return "support@yourcompany.com";
}

function sendMail($to, $from,$subject,$message,$headers = "") {
    $headers .= "From: ".$from."\r\n";
    return mail($to, $subject, $message, $headers);
}

function getMailForReporter() {
    return "Dear user,

Thanks for reporting this crash.

We will look into this issue as soon as possible.
It is likely we might contact you for more information regarding this crash.
For now: restart the application and you should be fine.

- Make sure you are using the latest version
Update your client by downloading the latest update via the site or
the Mac App Store. If update fails: remove the application and manually
download the application from the site or the Mac App Store.

- If you keep seeing the crash
Please contact us at support@yourcompany.com

Sorry for the inconvenience.

--
Best regards,
Your company
Your Name (support@yourcompany.com)
http://www.yourcompany.com";
}

function getReportMail() {
    return "CMCrashReporter:

Application: ".$_POST['application']."
App Version:    ".$_POST['appVersion']."
Mac os:    ".$_POST['osVersion']."
Time: ".$_POST['time']."
Date: ".$_POST['date']."
Mail: ".$_POST['mailaddress']."
Comments: ".$_POST['comments']."
Technical details:
".$_POST['rapport']."
";
    
}

function validMailaddress($mail) {
    // some regex check
    return $mail!="";
}

error_reporting(E_ERROR);
if ($_POST['type'] == "CMCrashReporter") {
    // Mail to yourself
    sendMail(technicalMailAddress(),technicalMailAddress(), "CrashReport: ".$_POST['application'],getReportMail());

    // Mail to the reporter
    if (validMailAddress($_POST['mailaddress']))
        sendMail($_POST['mailaddress'],technicalMailAddress(), "CrashReport of ".$_POST['application'],getMailForReporter());

    echo 'ok';
} else {
    echo '';
}
?>
