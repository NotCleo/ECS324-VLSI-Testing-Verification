class scoreboard;
  mailbox #(transaction) mon2sb;
  
  bit [4:0] shift_reg = 5'b00000;
  bit expected_dout;
  int trans_checked = 0; // Tracks completion

  function new(mailbox #(transaction) mon2sb);
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      transaction trans;
      mon2sb.get(trans);

      // 1. Reference Model Logic
      shift_reg = {shift_reg[3:0], trans.din};

      if (shift_reg == 5'b11011) begin
        expected_dout = 1'b1;
        shift_reg = 5'b00000; // Non-overlapping clear
      end else begin
        expected_dout = 1'b0;
      end

      // 2. Checking Logic
      if (trans.dout == expected_dout) begin
        $display("[SCOREBOARD] PASS %0d: din=%0b | actual_dout=%0b | expected_dout=%0b", trans_checked+1, trans.din, trans.dout, expected_dout);
      end else begin
        $error("[SCOREBOARD] FAIL %0d: din=%0b | actual_dout=%0b | expected_dout=%0b", trans_checked+1, trans.din, trans.dout, expected_dout);
      end
      
      trans_checked++; 
    end
  endtask
endclass