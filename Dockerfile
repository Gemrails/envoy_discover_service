From lyft/envoy-alpine
MAINTAINER pujielan@gmail.com

RUN apk --no-cache add bash
ADD start.sh /root/start.sh
RUN chmod 755 /root/start.sh
ENV ENVOY_BINARY="/usr/local/bin/envoy"

# 主动错误试验
COPY tcm /bin

WORKDIR /root

CMD ["./start.sh"]



