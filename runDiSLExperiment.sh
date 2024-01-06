if [ -z "${DISL_HOME}" ]; then
        echo "\$DISL_HOME needs to be defined."
        exit 1
fi


echo "======="
echo "SI"
./setup.sh &> setup_si.txt
cd frameworks/Kieker-java-sourceinstrumentation/
./runExponentialSizes.sh
mv exp-results ../SI-exp-results
cd ../../

echo "======="
echo "AspectJ"
./setup.sh &> setup_aspectj.txt
cd frameworks/Kieker-java
./runExponentialSizes.sh
mv exp-results ../AspectJ-exp-results
cd ../../

echo "======="
echo "DiSL"
./setup.sh &> setup_disl.txt
cd frameworks/Kieker-java-DiSL
./runExponentialSizes.sh
mv exp-results ../DiSL-exp-results
cd ../../
