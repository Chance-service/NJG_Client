#ifndef  _CORESDK_CONFIG_H_
#define  _CORESDK_CONFIG_H_

#include "cocos2d.h"

namespace coresdk {
	struct Config {
		std::string MerchantId;
		std::string ServiceId;
		std::string Domain;
		std::string ApiDomain;
		std::string PaymentDomain;
	};
};

#endif // _CORESDK_CONFIG_H_

