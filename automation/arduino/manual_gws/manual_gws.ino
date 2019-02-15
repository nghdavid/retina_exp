#include <Servo.h>
int d,d0;
Servo myservo;

void setup() 
{ 
  Serial.begin(9600);
  Serial.setTimeout(10); // 設定為每10毫秒結束一次讀取(數字愈小愈快)
  //myservo.write(d);
} 
int rest_time = 5, expt_time = 10; // in min.

void loop() 
{ 
  //int d = 0;
  if(Serial.available()){
//    d = atoi(cmd)
    d = Serial.parseInt();
    d0 = Serial.parseInt();
//    Serial.print(d);
//    Serial.print(" , ");
    if(0 <= d && d <= 360){   //180 for pull, 0 for push.
      myservo.attach(9);      // 連接數位腳位9，伺服馬達的訊號線
      myservo.write(d);
      delay(2000);
      myservo.detach();
    }
    
  }
//  else{
//    if(0 <= d && d <= 360){   //180 for pull, 0 for push.
//      myservo.attach(9);      // 連接數位腳位9，伺服馬達的訊號線
//      myservo.write(d);
////      Serial.println(myservo.read());
////    delay(2000);
////      myservo.detach();
//    }
//  }

}
