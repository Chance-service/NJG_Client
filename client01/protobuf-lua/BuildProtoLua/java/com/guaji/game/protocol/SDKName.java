// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: SDKName.proto

package com.guaji.game.protocol;

public final class SDKName {
  private SDKName() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
  }
  /**
   * Protobuf enum {@code PBSDKName}
   */
  public enum PBSDKName
      implements com.google.protobuf.ProtocolMessageEnum {
    /**
     * <code>default_channel = 1;</code>
     *
     * <pre>
     *默认
     * </pre>
     */
    default_channel(0, 1),
    /**
     * <code>yougu_channel_ios = 2;</code>
     *
     * <pre>
     *幽谷ios
     * </pre>
     */
    yougu_channel_ios(1, 2),
    /**
     * <code>yougu_channel_android = 3;</code>
     *
     * <pre>
     *幽谷Android
     * </pre>
     */
    yougu_channel_android(2, 3),
    ;

    /**
     * <code>default_channel = 1;</code>
     *
     * <pre>
     *默认
     * </pre>
     */
    public static final int default_channel_VALUE = 1;
    /**
     * <code>yougu_channel_ios = 2;</code>
     *
     * <pre>
     *幽谷ios
     * </pre>
     */
    public static final int yougu_channel_ios_VALUE = 2;
    /**
     * <code>yougu_channel_android = 3;</code>
     *
     * <pre>
     *幽谷Android
     * </pre>
     */
    public static final int yougu_channel_android_VALUE = 3;


    public final int getNumber() { return value; }

    public static PBSDKName valueOf(int value) {
      switch (value) {
        case 1: return default_channel;
        case 2: return yougu_channel_ios;
        case 3: return yougu_channel_android;
        default: return null;
      }
    }

    public static com.google.protobuf.Internal.EnumLiteMap<PBSDKName>
        internalGetValueMap() {
      return internalValueMap;
    }
    private static com.google.protobuf.Internal.EnumLiteMap<PBSDKName>
        internalValueMap =
          new com.google.protobuf.Internal.EnumLiteMap<PBSDKName>() {
            public PBSDKName findValueByNumber(int number) {
              return PBSDKName.valueOf(number);
            }
          };

    public final com.google.protobuf.Descriptors.EnumValueDescriptor
        getValueDescriptor() {
      return getDescriptor().getValues().get(index);
    }
    public final com.google.protobuf.Descriptors.EnumDescriptor
        getDescriptorForType() {
      return getDescriptor();
    }
    public static final com.google.protobuf.Descriptors.EnumDescriptor
        getDescriptor() {
      return com.guaji.game.protocol.SDKName.getDescriptor().getEnumTypes().get(0);
    }

    private static final PBSDKName[] VALUES = values();

    public static PBSDKName valueOf(
        com.google.protobuf.Descriptors.EnumValueDescriptor desc) {
      if (desc.getType() != getDescriptor()) {
        throw new java.lang.IllegalArgumentException(
          "EnumValueDescriptor is not for this type.");
      }
      return VALUES[desc.getIndex()];
    }

    private final int index;
    private final int value;

    private PBSDKName(int index, int value) {
      this.index = index;
      this.value = value;
    }

    // @@protoc_insertion_point(enum_scope:PBSDKName)
  }


  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\rSDKName.proto*R\n\tPBSDKName\022\023\n\017default_" +
      "channel\020\001\022\025\n\021yougu_channel_ios\020\002\022\031\n\025youg" +
      "u_channel_android\020\003B\031\n\027com.guaji.game.pr" +
      "otocol"
    };
    com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner assigner =
      new com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner() {
        public com.google.protobuf.ExtensionRegistry assignDescriptors(
            com.google.protobuf.Descriptors.FileDescriptor root) {
          descriptor = root;
          return null;
        }
      };
    com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
        }, assigner);
  }

  // @@protoc_insertion_point(outer_class_scope)
}
