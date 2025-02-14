#pragma once

#include "cocos2d.h"

#include "particle_nodes/firePngData.h"
USING_NS_CC;

class CCParticleFlow :
	public CCParticleSystemQuad
{
public:
	CCParticleFlow(void);
	~CCParticleFlow(void);

	virtual bool initWithTotalParticles(unsigned int numberOfParticles,ccColor4F startColor);

	static CCParticleFlow* createWithTotalParticles(unsigned int numberOfParticles,ccColor4F startColor);
};

class CCParticleBlink :
	public CCParticleSystemQuad
{
public:
	CCParticleBlink(void);
	~CCParticleBlink(void);

	virtual bool initWithTotalParticles(unsigned int numberOfParticles);

	static CCParticleBlink* createWithTotalParticles(unsigned int numberOfParticles);
};

