LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := protobuf_static
LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE_FILENAME := libprotobuf

LOCAL_SRC_FILES :=   ../src/google/protobuf/io/coded_stream.cc        \
  ../src/google/protobuf/stubs/atomicops_internals_x86_gcc.cc         \
  ../src/google/protobuf/stubs/common.cc                              \
  ../src/google/protobuf/stubs/once.cc                                \
  ../src/google/protobuf/stubs/stringprintf.cc                        \
  ../src/google/protobuf/extension_set.cc                             \
  ../src/google/protobuf/generated_message_util.cc                    \
  ../src/google/protobuf/message_lite.cc                              \
  ../src/google/protobuf/repeated_field.cc                            \
  ../src/google/protobuf/wire_format_lite.cc                          \
  ../src/google/protobuf/io/zero_copy_stream.cc                       \
  ../src/google/protobuf/io/zero_copy_stream_impl_lite.cc             \
  ../src/google/protobuf/stubs/strutil.cc                             \
  ../src/google/protobuf/stubs/substitute.cc                          \
  ../src/google/protobuf/stubs/structurally_valid.cc                  \
  ../src/google/protobuf/descriptor.cc                                \
  ../src/google/protobuf/descriptor.pb.cc                             \
  ../src/google/protobuf/descriptor_database.cc                       \
  ../src/google/protobuf/dynamic_message.cc                           \
  ../src/google/protobuf/extension_set_heavy.cc                       \
  ../src/google/protobuf/generated_message_reflection.cc              \
  ../src/google/protobuf/message.cc                                   \
  ../src/google/protobuf/reflection_ops.cc                            \
  ../src/google/protobuf/service.cc                                   \
  ../src/google/protobuf/text_format.cc                               \
  ../src/google/protobuf/unknown_field_set.cc                         \
  ../src/google/protobuf/wire_format.cc                               \
  ../src/google/protobuf/io/gzip_stream.cc                            \
  ../src/google/protobuf/io/printer.cc                                \
  ../src/google/protobuf/io/tokenizer.cc                              \
  ../src/google/protobuf/io/zero_copy_stream_impl.cc                  \
  ../src/google/protobuf/compiler/importer.cc                         \
  ../src/google/protobuf/compiler/parser.cc

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../src

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../src


include $(BUILD_STATIC_LIBRARY)
