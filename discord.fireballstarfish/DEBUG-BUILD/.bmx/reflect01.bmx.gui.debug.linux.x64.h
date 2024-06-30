#ifndef DISCORD_FIREBALLSTARFISH_REFLECT01_BMX_GUI_DEBUG_LINUX_X64_H
#define DISCORD_FIREBALLSTARFISH_REFLECT01_BMX_GUI_DEBUG_LINUX_X64_H

#include <brl.mod/blitz.mod/.bmx/blitz.bmx.debug.linux.x64.h>
#include <brl.mod/standardio.mod/.bmx/standardio.bmx.debug.linux.x64.h>
#include <brl.mod/reflection.mod/.bmx/reflection.bmx.debug.linux.x64.h>
int _bb_main();
struct _m_reflect01_TExample_obj;
void __m_reflect01_TExample_New(struct _m_reflect01_TExample_obj* o);
struct BBClass__m_reflect01_TExample {
	BBClass*  super;
	void      (*free)( BBObject *o );
	BBDebugScope* debug_scope;
	unsigned int instance_size;
	void      (*ctor)( BBOBJECT o );
	void      (*dtor)( BBOBJECT o );
	BBSTRING  (*ToString)( BBOBJECT x );
	int       (*Compare)( BBOBJECT x,BBOBJECT y );
	BBOBJECT  (*SendMessage)( BBOBJECT o,BBOBJECT m,BBOBJECT s );
	BBINTERFACETABLE itable;
	void*     extra;
	unsigned int obj_size;
	unsigned int instance_count;
	unsigned int fields_offset;
};

struct _m_reflect01_TExample_obj {
	struct BBClass__m_reflect01_TExample* clas;
	BBSTRING __m_reflect01_texample_name;
	BBSTRING __m_reflect01_texample_surname;
};
extern struct BBClass__m_reflect01_TExample _m_reflect01_TExample;

#endif
