/*
  One-line the Data_Get_Struct!
*/
#define Data_Fetch_Struct(obj, type) ({\
  type *type_ptr;\
  Data_Get_Struct(obj, type, type_ptr);\
  type_ptr;\
})

/*
  Make sure we’re OK, or raise an error with the message.
*/
#define ASSERT_OK(error) do {\
  if (error != SP_ERROR_OK) rb_raise(EHallon, "%s", sp_error_message(error));\
} while (0)

/*
  Make sure the given pointer is not a null pointer.
*/
#define ASSERT_NOT_EMPTY(ptr) do {\
  ASSERT_NOT_NULL(ptr);\
  ASSERT_NOT_NULL(*ptr);\
} while (0)

/*
  Make sure the given pointer is not a null pointer and that its’ value is not NULL.
*/
#define ASSERT_NOT_NULL(ptr) do {\
  if (ptr == NULL) rb_raise(EHallon, "%s is null (%s:%d)", #ptr, __FILE__, __LINE__);\
} while (0)

/*
  Write debug message to STDERR.
*/
#define DEBUG(msg) fprintf(stderr, "%s:%d -> %s\n", __FILE__, __LINE__, msg)