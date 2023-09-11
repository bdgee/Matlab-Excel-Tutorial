%Material names to access sheet in excel document
matNames = ["Copper"];

%Loops through each material to extract and compile data for each material
for i = 1:6

    %Collects the data for the material
    %First col is extension (mm)
    %Second col is load(kN)
    %Third col are gauge length, gauge width, gauge thickness (mm)

    data = readtable("All_Raw_Data.xlsx", 'Sheet', "Copper");
    
    %Extracts the dimension data
    dimData = data{1:3, 3}';
    gaugeLength = dimData(1);
    gaugeWidth = dimData(2);
    gaugeThick = dimData(3);

    %Calculates the area in m^2
    gaugeArea = gaugeWidth * gaugeThick/(1000^2);
    
    %Strain (unitless)
    x = data{:, 1}'/gaugeLength;
    
    %Stress (MPa)
    y= data{:, 2}'*1000/gaugeArea/(10^6);

    %Filters the ending data noise
    numChange1 = 8;

    idx = find(ischange(y, 'linear', 'MaxNumChanges', numChange1));
    x = x(1:idx(numChange1-1));
    y = y(1:idx(numChange1-1));

    %What I have to do is create a function that looks at the beginning of
    %the data and how many points are in each linear change, and choose the
    %range that has the maximum number of points with a positive slope
    
    %First, I need to find the slopes between the two points and choose the
    %greatest one
    numChange2 = 4;
    idx = find(ischange(y, 'linear', 'MaxNumChanges', numChange2-1));
    
    slopes =   diff(y([1, idx, end])) ./diff(x([1, idx, end]));
    [maxSlope, back_idx] = max(slopes);

    back = idx(back_idx);
    
    front = 1;

    if back_idx ~=1
        front = idx(back_idx - 1);
    end

    eqn = polyfit(x(front:back),y(front:back), 1);

    %Enables creation of new plot
    figure();

    %Plots the graph
    area(x,y, 'LineWidth',1, 'FaceAlpha', 0.1);

    %Plots the linear line for modulus
    hold on
    lineY = x .* eqn(1) + eqn(2);
    intercept = max(y((abs(y -lineY)) < 1));
    intInd = find(y == intercept);
    
    %Defines window
    xlim([0 max(x)*1.1]);
    ylim([0 max(y)*1.1]);

    %Creates Titles
    title("Copper: Stress vs. Strain");
    ylabel("Stress (MPa)");
    xlabel("Strain (mm/mm)");

    %Gets elastic modulus
    elasticModulus = eqn(1)/1000;

    %Gets and plots yield strength
    yieldStrengthEqn = [eqn(1), -1* eqn(1)*(.002)+eqn(2)];
    yieldStrengthY = x .* yieldStrengthEqn(1) + yieldStrengthEqn(2);
    yieldStrength = max(y((abs(y-yieldStrengthY)) < 1));

    %Gets and plots tensile strength
    tensileStrength = max(y);
    
    %Gets and plots ductility
    ductility = x(end)-y(end)/eqn(1);

    %Gets and plots toughness
    areaUnder = cumtrapz(x,y);
    toughness = areaUnder(end);

    
    switch i
        case 1
            text(x(round((front+intInd)/2)), y(round((front+intInd)/2)), '1', 'FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
            plot(x(find(y==yieldStrength, 1)), yieldStrength, 'o', 'MarkerSize', 10, 'Color', 'blue');
            text(x(find(y==yieldStrength, 1)), yieldStrength, '2','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
            plot(x(find(y==tensileStrength, 1)), tensileStrength, 'o','MarkerSize',10, 'Color', 'g');
            text(x(find(y==tensileStrength, 1)), tensileStrength, '3','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
            plot(ductility, 0, 'o', 'MarkerSize', 10, 'Color', 'cyan');
            text(ductility, 0, '4', 'FontSize', 15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
            text(x(find(y==tensileStrength, 1)), tensileStrength/3, '5','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
        case 2
            plot(x(front:intInd), polyval(eqn, x(front:intInd)), 'LineWidth',2, 'Color', 'r', 'LineStyle','--');
            text(x(round((front+intInd)/2)), y(round((front+intInd)/2)), '1', 'FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
        case 3
            plot(x(front:find(y == yieldStrength)), polyval(yieldStrengthEqn, x(front:find(y == yieldStrength))), 'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
            plot(x(find(y==yieldStrength, 1)), yieldStrength, 'o', 'MarkerSize', 10, 'Color', 'blue');
            text(x(find(y==yieldStrength, 1)), yieldStrength, '2','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
        case 4
            plot(x(find(y==tensileStrength, 1)), tensileStrength, 'o','MarkerSize',10, 'Color', 'g');
            text(x(find(y==tensileStrength, 1)), tensileStrength, '3','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
        case 5
            plot(ductility, 0, 'o', 'MarkerSize', 10, 'Color', 'cyan');
            text(ductility, 0, '4', 'FontSize', 15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
        case 6
            text(x(find(y==tensileStrength, 1)), tensileStrength/3, '5','FontSize',15, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
    end

end



