%对于选用不同的模型，需要修改参数的上下区间和参数的初值
%选用不同的参数模型，需要更改lambd、D_array(t)和price
clc
clear 
alpha_down=-0.2;  %alpha_down=10^(-10);
alpha_up=1;
beta_down=0.3;
beta_up=1.0;
sigma=0.25;
rou=0.75;
s=0;
for i=1:1:500
     alpha1=unifrnd (alpha_down,alpha_up);
     beta1=unifrnd (beta_down,beta_up);
     p_star=1/beta1;
     rmax=p_star*(exp(alpha1-beta1*p_star));
    A=0;
    max=0;
    price=1;
    t=0;
    for T=1:1:100
%          lambd=alpha-beta*price;    %线性
           lambd=exp(alpha1-beta1*price)+normrnd(0,sigma);     %指数
%          lambd=exp(alpha-beta*price)/(1+exp(alpha-beta*price));    %分对数
        t=t+1;
        D1_array(t)=lambd;
        price_array(t)=price;
        D_array(t)=lambd;   %线性
%          D_array(t)=log(lambd);   %指数
        %if log(lambd/(1-lambd))==inf    %分对数
            %D_array(t)=3;
        %else
           % D_array(t)=log(lambd/(1-lambd));
        %end
         price=price+rou*(t^(-1/4));
        if price>5
            price=5;
        elseif price<=0
            price=10^(-10);
        end
        lambd=exp(alpha1-beta1*price);
        D=lambd+normrnd(0,sigma);
%         if D>1
%             D=1;
%         elseif D<=0
%             D=10^(-10);
%         end
        t=t+1;
        price_array(t)=price;
        D_array(t)=D;    %线性
%          D_array(t)=log(D);    %指数
%         if log(D/(1-D))==inf    %分对数
%            D_array(t)=3;
%         else
%             D_array(t)=log(D/(1-D));
%         end
        D1_array(t)=D;
%         price=price+rou*(t^(-1/4));
%         if price>5
%             price=5;
%         elseif price<=0
%             price=10^(-10);
%         end
%         price_array(t)=price;
        r_p=price*lambd;
        r_p_array(t-1)=r_p;
        if(r_p>max)
            max=r_p;
        end
        r_p=price*D;
        r_p_array(t)=r_p;
        
        A=A+r_p_array(t-1)+r_p_array(t);
        fit_parameter=polyfit(price_array,D_array,1);
        beta=-fit_parameter(1);
        alpha=fit_parameter(2);
        %每次拟合参数后要调整参数，使之介于合理的参数范围内
%         if alpha>alpha_up
%             alpha=alpha_up;
%         elseif alpha<alpha_down
%             alpha=alpha_down;
%         end
%         if beta>beta_up
%             beta=beta_up;
%         elseif beta<beta_down
%             beta=beta_down;
%         end
           price=alpha/(2*beta);    %线性
%            price=1/beta;    %指数
%         price=(lambertw(0, exp(-1)*exp(alpha)) + 1)/beta;    %分对数
        if price>5
            price=5;
        elseif price<=0
            price=10^(-10);
        end
    end
    Optimal_profit=2*T*rmax;
    s=s+A/Optimal_profit
end
means=s/500
plot(price_array,D_array)
%scatter(price_array,D1_array,'r*')
hold on;
scatter(price_array,r_p_array,'r*')