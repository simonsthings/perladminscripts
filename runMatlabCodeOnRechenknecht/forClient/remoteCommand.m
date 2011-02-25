
x0=[ 7   -6    1.2  -55    0.005 ]
historyindices = 1:1:3000; [bgNetwork,rs,weightsCCSM,weightsSMSNr]=StaticClassBGTests.testLearningXOR(x0,historyindices,[],[],[]); StaticClassBGDisplay.showLayerHistory(2203,bgNetwork,'Outputs',2,0);   StaticClassBGDisplay.showDifferentiationMap(60,bgNetwork,rs,patterns);


