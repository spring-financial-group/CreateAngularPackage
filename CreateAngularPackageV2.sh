set -e

specurl=$1
packageversion=$2

echo Spec Url $specurl
echo Version $packageversion

mkdir -p ./service

case $specurl in
    "http"*) 
		echo Downloading spec file
		curl --max-time 300 $specurl > ./spec.json	;;
    *) 
		echo Copying spec file
		cp $specurl ./spec.json ;;
esac

npx openapi-generator generate -i ./spec.json -g typescript-angular -o service --additional-properties=fileNaming=camelCase --enable-post-process-file

sed -i 's/0.0.0/'$packageversion'/g' ./package.json

cp ./package.json ./service/package.json 
cp ./tsconfig.json ./service/tsconfig.json 

cd service

npm install --save rxjs
npm install --save zone.js@0.9.1
npm install --save @angular/core@8.2.14 
npm install --save @angular/common@8.2.14 

ngc

cd ..

cp ./.npmrc ./dist/.npmrc
cp ./package.json ./dist/package.json

cd dist

npm publish