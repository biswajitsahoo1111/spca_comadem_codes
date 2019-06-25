# R version 3.5.3 (2019-03-11)
library(e1071)
library(ggplot2)
library(lars)
library(elasticnet)

rm(list = ls()) # Cleans your workspace environment
dat = read.csv("D:/rfiles/feature_matrix_wav_ent8_1024_ims.csv",header = T)
# Training and Test Set
set.seed(1)
index = c(sample(1:460,450),sample(461:920,450),
          sample(921:1380,450),sample(1381:1840,450))
data = dat[index,]
new_index = c(sample(1:450,150),sample(451:(2*450),150),
              sample((2*450+1):(3*450),150),sample((3*450+1):(4*450),150))
test = data[new_index,]
train = data[-new_index,]
rm("data")

##############################################
# Regular PCA

regular.pca = prcomp(train[,-dim(train)[2]],scale = T)
# Percentage variance explained plot
expl.var = cumsum(regular.pca$sdev^2)/sum(regular.pca$sdev^2)
round(regular.pca$rotation[,1:2],3)
round(expl.var[1:2],3)
write.csv(round(regular.pca$rotation[,1:2],3),'loadings_pca_wav_ent8_ims.csv',
          row.names = F)
ggplot(data = data.frame(x = 1:8,y = expl.var),mapping = aes(x = x,y = y))+
  geom_point()+ylim(c(0,1))+xlab('Number of principal components')+
  ylab('Percentage of variance explained')+geom_line()+
  scale_x_continuous(minor_breaks = 1:8,breaks = 1:8)
  
ggsave("pecentage_var_expl_wav_ent8_ims.jpg",width = 4,height = 4)
# Projection on first 2 Principal Components
ggdata = data.frame(regular.pca$x[,1:2],y=train[,dim(train)[2]])
ggplot(ggdata, 
       mapping = aes(x = ggdata[,1],y = ggdata[,2],col = ggdata[,3]))+
  geom_point()+labs(x = 'PC score along PC1',y='PC score along PC2',
                    col = 'Fault Type')+
  scale_color_manual(values = c('red','blue','purple','green'))
ggsave("regular_pca_projection_wav_ent8_ims.jpg",width = 4,height = 4)

##########################
# Sparse PCA
# 4 components
spca.result_4 = spca(cor(train[,-dim(train)[2]]),K = 2,para = c(4,4),
                     type = 'Gram',sparse = "varnum",max.iter = 500)
spca.result_4
write.csv(round(spca.result_4$loadings,3),'loadings_spca_wav_ent8_ims_4.csv',
          row.names = F)
round(cumsum(spca.result_4$pev),3)

# Projection using SPCA (with 4 features)
newdata = scale(as.matrix(train[,-dim(train)[2]])) %*% spca.result_4$loadings
ggdata = data.frame(newdata,y=train[,dim(train)[2]])
ggplot(ggdata, 
       mapping = aes(x = ggdata[,1],y = ggdata[,2],col = ggdata[,3]))+
  geom_point()+labs(x = 'Modified PC score along PC1',
                    y = 'Modified PC score along PC2',
                    col = 'Fault Type')+
  scale_color_manual(values = c('red','blue','purple','green'))
ggsave("spca_projection_wav_ent8_ims_4.jpg",width = 4,height = 4)

##########################
# Multicalss SVM using all features
set.seed(1)
tune.out = tune(svm,fault_type~., data = train,kernel = 'radial',
                ranges = list(cost = c(1,5,10,50,100),
                              gamma = c(0.05,0.5,1,5,10)))
# To check training accuracy
pred.train = predict(tune.out$best.model,train)
table(pred.train,train[,dim(train)[2]])

# To check Test accuracy
pred.test = predict(tune.out$best.model,test)
table(pred.test,test[,dim(test)[2]])

########################
# Using SPCA features (wavelet entropy)
train.sub = subset(train,select= c(paste0("En",c(1,5,6,8)),'fault_type'))
test.sub = subset(test,select = c(paste0("En",c(1,5,6,8)),'fault_type'))
svmfit = svm(fault_type~.,data = train.sub,kernel = 'radial',
             cost = 1,gamma = 0.05)
table(svmfit$fitted,train.sub[,dim(train.sub)[2]])
pred.test.sub = predict(svmfit,test.sub)
table(pred.test.sub,test.sub[,dim(test.sub)[2]])

# Threshodling feautures (Top 4 feature of regular PCA with decreasing magnitude)
train.sub = subset(train,select= c(paste0("En",c(5:8)),'fault_type'))
test.sub = subset(test,select = c(paste0("En",c(5:8)),'fault_type'))
svmfit = svm(fault_type~.,data = train.sub,kernel = 'radial',
             cost = 1,gamma = 0.05)
table(svmfit$fitted,train.sub[,dim(train.sub)[2]])
pred.test.sub = predict(svmfit,test.sub)
table(pred.test.sub,test.sub[,dim(test.sub)[2]])

############################
# Effect of choosing a differnt training set
# 4 featuers
mat = array(rep(0,1000),dim = c(100,10))
k = 0
for (i in seq(1,by= 5,length = 100)){
  k = k+1
  set.seed(i)
  index = c(sample(1:460,300),sample(461:920,300),
            sample(921:1380,300),sample(1381:1840,300))
  train_sample = dat[index,]
  spca.result = spca(cor(train_sample[,-dim(train_sample)[2]]),K = 2,
                     para = c(4,4),
                     sparse = "varnum",trace = F,
                     type = "Gram")
  mat[k,1:(dim(train)[2]-1)] = spca.result$loadings[,1]
  mat[k,10]=spca.result$pev[1]
}
x = rep(0,(dim(train)[2]-1))
for (i in 1:(dim(train)[2]-1)){
  x[i] = sum(mat[,i]!=0)
}
ggplot(as.data.frame(x),aes(x = 1:(dim(train)[2]-1),y = x))+geom_bar(stat = 'identity')+
  labs(x= 'Features',y = 'Frequency')+
  scale_x_discrete(limit =c(paste0("WP-",1:(dim(train)[2]-1))) )+
  scale_y_discrete(limit = seq(0,100,by = 10))+
  theme(axis.text.x =element_text(angle = 30))
ggsave("random_training_wav_ent8_ims_4.jpg",width = 4, height = 4)
