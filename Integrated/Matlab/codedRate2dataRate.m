function dataRate = codedRate2dataRate(x)


    if(x == [1, 1, 0, 1])
        dataRate = 6;
    end
    if(x == [1, 1, 1, 1])
        dataRate = 9;
    end
    if(x == [0, 1, 0, 1])
        dataRate = 12;
    end
    if(x == [0, 1, 1, 1])
        dataRate = 18;
    end
    if(x == [1, 0, 0, 1])
        dataRate = 24;
    end
    if(x == [1, 0, 1, 1])
        dataRate = 36;
    end
    if(x == [0, 0, 0, 1])
        dataRate = 48;
    end
    if(x == [0, 0, 1, 1])
        dataRate = 54;
    end

end