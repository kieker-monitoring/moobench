if [ -z "${DISL_HOME}" ]; then
        echo "\$DISL_HOME needs to be defined."
        exit 1
fi


echo "======="
echo "SI"
git checkout disl
./setup.sh &> setup_si.txt
cd frameworks/Kieker-java-sourceinstrumentation/
./runExponentialSizes.sh
mv exp-results ../SI-exp-results
cd ../../

echo "======="
echo "AspectJ"
git checkout Kieker-1.15.2-OperationExecutionRecord
./setup.sh &> setup_aspectj.txt
cd frameworks/Kieker-java
./runExponentialSizes.sh
mv exp-results ../AspectJ-exp-results
cd ../../

echo "======="
echo "DiSL"
git checkout disl
./setup.sh &> setup_disl.txt
cd frameworks/Kieker-java-DiSL
./runExponentialSizes.sh
mv exp-results ../DiSL-exp-results
cd ../../
