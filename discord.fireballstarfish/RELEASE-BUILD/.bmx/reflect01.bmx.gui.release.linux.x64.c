#include "reflect01.bmx.gui.release.linux.x64.h"
struct BBString_4{BBClass_String* clas;BBULONG hash;int length;BBChar buf[4];};
static struct BBString_4 _s0={
	&bbStringClass,
	0xcb18ac0232a6a4c1,
	4,
	{68,111,110,101}
};
struct BBDebugScope_3{int kind; const char *name; BBDebugDecl decls[4]; };
void __m_reflect01_TExample_New(struct _m_reflect01_TExample_obj* o) {
	bbObjectCtor((BBOBJECT)o);
	o->clas = &_m_reflect01_TExample;
	o->__m_reflect01_texample_name = ((BBString*)&bbEmptyString);
	o->__m_reflect01_texample_surname = ((BBString*)&bbEmptyString);
}
void __m_reflect01_TExample_New_ReflectionWrapper(void** buf){
	__m_reflect01_TExample_New(
		*(struct _m_reflect01_TExample_obj**)(buf)
	);
}
struct BBDebugScope_3 _m_reflect01_TExample_scope ={
	BBDEBUGSCOPE_USERTYPE,
	"TExample",
	{
		{
			BBDEBUGDECL_FIELD,
			"name",
			"$",
			.field_offset=offsetof(struct _m_reflect01_TExample_obj,__m_reflect01_texample_name),
			(void (*)(void**))0
		},
		{
			BBDEBUGDECL_FIELD,
			"surname",
			"$",
			.field_offset=offsetof(struct _m_reflect01_TExample_obj,__m_reflect01_texample_surname),
			(void (*)(void**))0
		},
		{
			BBDEBUGDECL_TYPEMETHOD,
			"New",
			"()",
			.func_ptr=(BBFuncPtr)&__m_reflect01_TExample_New,
			&__m_reflect01_TExample_New_ReflectionWrapper
		},
		{
			BBDEBUGDECL_END,
			(char*)0,
			(char*)0,
			.var_address=(void*)0,
			(void (*)(void**))0
		}
	}
};
struct BBClass__m_reflect01_TExample _m_reflect01_TExample={
	&bbObjectClass,
	bbObjectFree,
	(BBDebugScope*)&_m_reflect01_TExample_scope,
	sizeof(struct _m_reflect01_TExample_obj),
	(void (*)(BBOBJECT))__m_reflect01_TExample_New,
	bbObjectDtor,
	bbObjectToString,
	bbObjectCompare,
	bbObjectSendMessage,
	0,
	0,
	offsetof(struct _m_reflect01_TExample_obj,__m_reflect01_texample_surname) - offsetof(struct _m_reflect01_TExample_obj,__m_reflect01_texample_name) + sizeof(BBSTRING)
	,0
	,offsetof(struct _m_reflect01_TExample_obj,__m_reflect01_texample_name)
};

static int _bb_main_inited = 0;
int _bb_main(){
	if (!_bb_main_inited) {
		_bb_main_inited = 1;
		__bb_brl_blitz_blitz();
		__bb_brl_standardio_standardio();
		__bb_brl_reflection_reflection();
		bbObjectRegisterType((BBCLASS)&_m_reflect01_TExample);
		brl_blitz_DebugStop();
		struct _m_reflect01_TExample_obj* bbt_example=(struct _m_reflect01_TExample_obj*)(struct _m_reflect01_TExample_obj*)bbObjectNew((BBClass *)&_m_reflect01_TExample);
		struct brl_reflection_TTypeId_obj* bbt_tid=(struct brl_reflection_TTypeId_obj*)brl_reflection_TTypeId_ForObject_TTTypeId_TObject((BBOBJECT)bbt_example);
		brl_standardio_Print((BBString*)&_s0);
		return 0;
	}
	return 0;
}