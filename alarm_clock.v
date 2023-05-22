module AlarmClock(
    input wire clock,                    // Saat sinyali
    input wire reset,                    // Sıfırlama sinyali
    input wire alarm_set,                // Alarm ayarı sinyali
    input wire [5:0] alarm_hours,        // Alarm saat değeri (0-59)
    input wire [5:0] alarm_minutes,      // Alarm dakika değeri (0-59)
    output reg [2:0] led                  // LED çıkışı
);

    reg [25:0] count;                     // Sayaç
    reg [5:0] hours;                      // Saat değeri (0-23)
    reg [5:0] minutes;                    // Dakika değeri (0-59)
    reg [5:0] seconds;                    // Saniye değeri (0-59)
    reg alarm_active;                     // Alarm durumu
    reg [3:0] timer_count;                // Timer sayacı
    reg timer_active;                     // Timer durumu

    always @*
    begin
        if (reset)                          // Reset sinyali tetiklenirse;
        begin
            count <= 0;                     // Sayaç sıfırlanır
            alarm_active <= 0;              // Alarm durumu sıfırlanır
            led <= 3'b110;                  // Kırmızı LED
            timer_count <= 4'd0;             // Timer sayacı sıfırlanır
            timer_active <= 0;               // Timer durumu sıfırlanır
        end
        else if (count == 25000000)         // Buradaki 25.000.000 değeri, osilatörün frekansına göre değişiklik gösterebilir.
        begin
            count <= 0;                     // Sayaç sıfırlanır
            if (seconds == 6'b010101)
            begin
                seconds <= 6'b000000;        // Saniye değerini sıfırlama
                if (minutes == 6'b010101)
                begin
                    minutes <= 6'b000000;    // Dakika değerini sıfırlama
                    if (hours == 6'b001111)
                        hours <= 6'b000000;   // Saat değerini sıfırlama
                    else
                        hours <= hours + 1;    // Saat değerini bir artırma
                end
                else
                    minutes <= minutes + 1;   // Dakika değerini bir artırma
            end
            else
                seconds <= seconds + 1;       // Saniye değerini bir artırma
        end
        else
            count <= count + 1;               // Sayaç değerini bir artırma

        // Şu anki saat değerleri ile alarm saat değerleri aynı ise;
        if (alarm_set && (hours == alarm_hours) && (minutes == alarm_minutes) && (seconds == 6'b000000))
        begin
            alarm_active <= 1;                // Alarm durumunu tetikle
            led <= 3'b011;                    // Yeşil LED
            timer_active <= 1;                // Alarm timer aktif
        end
        else
        begin
            alarm_active <= 0;                // Alarm durumunu sıfırla
            led <= 3'b110;                    // Kırmızı LED
        end
        
        // Timer işlevi
        if (timer_active)
        begin
            if (timer_count == 4'd10)         // Timer 10 saniye boyunca çalıştırılır
            begin
                timer_active <= 0;            // Timer durumunu sıfırla
                led <= 3'b011;                // LED'leri söndür
            end
            else
                timer_count <= timer_count + 1;  // Timer sayacını bir artır
        end
        else if (alarm_active && (minutes == alarm_minutes + 1))  // Alarm tetiklendikten 1 dakika sonra timer aktif hale gelsin
        begin
            timer_active <= 1;                // Timer durumunu tetikle
            timer_count <= 4'd0;               // Timer sayacını sıfırla
            led <= 3'b110;                    // LED'leri yak
        end
    end

endmodule