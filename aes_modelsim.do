onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Global Signals}
add wave -noupdate /tb_aes_top/uut/clk
add wave -noupdate /tb_aes_top/uut/reset
add wave -noupdate /tb_aes_top/uut/start
add wave -noupdate /tb_aes_top/uut/done
add wave -noupdate -divider {AES I/O}
add wave -noupdate -radix hexadecimal /tb_aes_top/uut/key
add wave -noupdate -radix hexadecimal /tb_aes_top/uut/plaintext
add wave -noupdate -radix hexadecimal /tb_aes_top/uut/ciphertext
add wave -noupdate -divider {Internal State}
add wave -noupdate -radix hexadecimal /tb_aes_top/uut/state_reg_out
add wave -noupdate -radix hexadecimal /tb_aes_top/uut/key_reg_out
add wave -noupdate -radix unsigned /tb_aes_top/uut/round_number
add wave -noupdate -radix unsigned /tb_aes_top/uut/u_controller/current_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1104050 ps} {1105050 ps}
