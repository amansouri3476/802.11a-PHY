for i=1:64
    b = trellis.outputs(i,1);
    if b==0
        disp(['error_adder #(.m(err_len-1)) err_add', num2str(i-1), '(.error(err_add_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .a(x), .error_0_in(err_0_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .error_1_in(err_1_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]));']);
    elseif b==1
        disp(['error_adder1 #(.m(err_len-1)) err_add', num2str(i-1), '(.error(err_add_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .a(x), .error_0_in(err_0_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .error_1_in(err_1_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]));']);
    elseif b==2
        disp(['error_adder2 #(.m(err_len-1)) err_add', num2str(i-1), '(.error(err_add_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .a(x), .error_0_in(err_0_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .error_1_in(err_1_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]));']);
    else
        disp(['error_adder3 #(.m(err_len-1)) err_add', num2str(i-1), '(.error(err_add_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .a(x), .error_0_in(err_0_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]), .error_1_in(err_1_in[', num2str(i), '*err_len-1:', num2str(i-1), '*err_len]));']);
    end
end