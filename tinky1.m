%对于选用不同的模型，需要修改参数的上下区间和参数的初值
%选用不同的参数模型，需要更改lambd、D_array(t)和price
clc
clear 
alpha_down=20;  %alpha_down=10^(-10);
alpha_up=30;
beta_down=1.2;
beta_up=2.0;
service_up=0.8;
service_down=0.2;
sigma=0.25;
rou=0.5;
s=0;
for i=1:1:500
    k=0.5;
%     alpha=25;
%    beta=1.2;
%     gamma=0.8;
     alpha1=unifrnd (alpha_down,alpha_up);
     beta1=unifrnd (beta_down,beta_up);
     gamma1=unifrnd (service_down,service_up);
     [pri,ser] = meshgrid(0:0.1:5);
     De=exp(alpha1-beta1.*pri+gamma1.*ser);
     f=pri.*De-(k.*ser).*De;
     R_rest=max(f(:));
%     res_max=[];
    
    A=0;
     max1=0;
    price=1;
    service=1.2;
    t=0;
%     [price_test,service_test]=ndgrid(0:0.1:5);
%     De=exp(alpha-beta*price_test+gamma*service_test);
%     f=price_test.*De-(k*service_test).*De;
%     res_max=[price_test(f==max(f(:)))  service_test(f==max(f(:)))  max(f(:))] ;
%     R_test=res_max(3);
    for T=1:1:100
        lambd=exp(alpha1-beta1*price+gamma1*service)+normrnd(0,sigma);    %指数
        %lambd=exp(alpha-beta*price);     %指数
%        lambd=exp(alpha-beta*price+gamma*service)/(1+exp(alpha-beta*price+gamma*service));   %分对数
        t=t+1;
        D1_array(t)=lambd;
        price_array(t)=price;
        service_array(t)=service;
        %if log(lambd/(1-lambd))==inf    %分对数
        a(t)=service;
        D_array(t)=lambd;   %线性
        %D_array(t)=log(lambd);   %指数
            %D_array(t)=3;
        %else
           % D_array(t)=log(lambd/(1-lambd));
        %end
        price=price+rou*(t^(-1/4));
        service=service+rou*(t^(-1/4));
         if price>5
            price=5;
        elseif price<=0
            price=10^(-10);
        end
        if service>5
            service=5;
        elseif service<=0
            service=10^(-10);
        end
        lambd=exp(alpha1-beta1*price+gamma1*service);
        D=lambd+normrnd(0,sigma);
%         if D>5.0e+10
%             D=5.0e+10;
%         elseif D<=0
%             D=10^(-10);
%         end
        t=t+1;
        D_array(t)=D;    %线性
        %D_array(t)=log(D);    %指数
%         if log(D/(1-D))==inf    %分对数
%            D_array(t)=3;
%         else
%             D_array(t)=log(D/(1-D));
%         end
        D1_array(t)=D;
        
       
        price_array(t)=price;
        service_array(t)=service;
        r_ps=price*lambd-k*service*lambd;
        r_ps_array(t-1)=r_ps;
        if(r_ps>max1)
            max1=r_ps;
        end
        r_ps=price*D-k*service*D;
        if(r_ps>max1)
            max1=r_ps;
        end
        r_ps_array(t)=r_ps;
        A=A+r_ps_array(t-1)+r_ps_array(t);
         price_trans=price_array';
         service_trans=service_array';
         D_trans=D_array';
        X=[ones(size(D_trans)) price_trans service_trans];
        [b,bint,r,rint,stats] = regress(D_trans,X);
        alpha=b(1);
        beta=-b(2);
        gamma=b(3);
%         alpha_array(t)=alpha;
%         beta_array(t)=beta;
%         gamma_array(t)=gamma;
%         fit_parameter=polyfit(price_array,D_array,1);
%         beta=-fit_parameter(1);
%         alpha=fit_parameter(2);
        %每次拟合参数后要调整参数，使之介于合理的参数范围内
        if alpha>alpha_up
            alpha=alpha_up;
        elseif alpha<alpha_down
            alpha=alpha_down;
        end
        if beta>beta_up
            beta=beta_up;
        elseif beta<beta_down
            beta=beta_down;
        end
        if gamma>service_up
            gamma=service_up;
        elseif gamma<service_down
            gamma=service_down;
        end
        alpha_array(t)=alpha;
        beta_array(t)=beta;
        gamma_array(t)=gamma;
        price=-(alpha*k)/(gamma - beta*k);   %线性
        service=-alpha/(gamma - beta*k);
        %price=1/beta;    %指数
        %price=(lambertw(0, exp(-1)*exp(alpha)) + 1)/beta;    %分对数
        if price>5
            price=5;
        elseif price<=0
            price=10^(-10);
        end
         if service>5
            service=5;
        elseif service<=0
            service=10^(-10);
        end
    end
    Optimal_profit=2*T*R_rest;
    s=s+A/Optimal_profit
end
means=s/500
%plot(price_array,D_array)
%scatter(price_array,D1_array,'r*')
%scatter(price_array,r_p_array,'r*')