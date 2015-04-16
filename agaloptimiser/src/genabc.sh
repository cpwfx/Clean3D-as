java -jar $SDK/usr/lib/asc2.jar -merge -md -d -abcfuture -AS3 \
   -out agaloptimiser -outdir . -import $SDK/usr/lib/builtin.abc -import $SDK/usr/lib/playerglobal.abc \
   com/adobe/AGALOptimiser/nsinternal.as \
   com/adobe/AGALOptimiser/nsdebug.as \
   com/adobe/AGALOptimiser/agal/BasicBlock.as \
   com/adobe/AGALOptimiser/agal/BasicBlockAnalyzer.as \
   com/adobe/AGALOptimiser/agal/BinaryPrettyPrinter.as \
   com/adobe/AGALOptimiser/agal/CloningContext.as \
   com/adobe/AGALOptimiser/agal/Value.as \
   com/adobe/AGALOptimiser/agal/SimpleValue.as \
   com/adobe/AGALOptimiser/agal/ConstantValue.as \
   com/adobe/AGALOptimiser/agal/ConstantBooleanValue.as \
   com/adobe/AGALOptimiser/agal/ConstantFloatValue.as \
   com/adobe/AGALOptimiser/agal/ConstantIntValue.as \
   com/adobe/AGALOptimiser/agal/ConstantMatrixValue.as \
   com/adobe/AGALOptimiser/agal/Constants.as \
   com/adobe/AGALOptimiser/agal/DefinitionLine.as \
   com/adobe/AGALOptimiser/agal/DefinitionLineAnalyzer.as \
   com/adobe/AGALOptimiser/agal/DestinationRegister.as \
   com/adobe/AGALOptimiser/agal/Disassembler.as \
   com/adobe/AGALOptimiser/agal/Operation.as \
   com/adobe/AGALOptimiser/agal/Instruction.as \
   com/adobe/AGALOptimiser/agal/LiveRange.as \
   com/adobe/AGALOptimiser/agal/LiveRangeAnalyzer.as \
   com/adobe/AGALOptimiser/agal/LocationRange.as \
   com/adobe/AGALOptimiser/agal/Opcode.as \
   com/adobe/AGALOptimiser/agal/Procedure.as \
   com/adobe/AGALOptimiser/agal/Program.as \
   com/adobe/AGALOptimiser/agal/ProgramCategory.as \
   com/adobe/AGALOptimiser/agal/Register.as \
   com/adobe/AGALOptimiser/agal/RegisterCategory.as \
   com/adobe/AGALOptimiser/agal/RegisterCategorySet.as \
   com/adobe/AGALOptimiser/agal/SampleCategory.as \
   com/adobe/AGALOptimiser/agal/SampleOperation.as \
   com/adobe/AGALOptimiser/agal/SampleOptions.as \
   com/adobe/AGALOptimiser/agal/SampleSourceRegister.as \
   com/adobe/AGALOptimiser/agal/SourceRegister.as \
   com/adobe/AGALOptimiser/agal/Swizzle.as \
   com/adobe/AGALOptimiser/agal/TextureValue.as \
   com/adobe/AGALOptimiser/agal/VertexValue.as \
   com/adobe/AGALOptimiser/agal/WriteMask.as \
   com/adobe/AGALOptimiser/Constants.as \
   com/adobe/AGALOptimiser/error/Enforcer.as \
   com/adobe/AGALOptimiser/error/ErrorMessages.as \
   com/adobe/AGALOptimiser/GlobalID.as \
   com/adobe/AGALOptimiser/NumericalConstantInfo.as \
   com/adobe/AGALOptimiser/RegisterElement.as \
   com/adobe/AGALOptimiser/RegisterElementGroup.as \
   com/adobe/AGALOptimiser/RegisterInfo.as \
   com/adobe/AGALOptimiser/ParameterRegisterInfo.as \
   com/adobe/AGALOptimiser/Semantics.as \
   com/adobe/AGALOptimiser/TextureRegisterInfo.as \
   com/adobe/AGALOptimiser/translator/transformations/Transformation.as \
   com/adobe/AGALOptimiser/translator/transformations/Constants.as \
   com/adobe/AGALOptimiser/translator/transformations/ConstantVectorizer.as \
   com/adobe/AGALOptimiser/translator/transformations/DeadCodeEliminator.as \
   com/adobe/AGALOptimiser/translator/transformations/DestinationRegisterTemplate.as \
   com/adobe/AGALOptimiser/translator/transformations/IdentityMoveRemover.as \
   com/adobe/AGALOptimiser/translator/transformations/InstructionTemplate.as \
   com/adobe/AGALOptimiser/translator/transformations/InterferenceGraph.as \
   com/adobe/AGALOptimiser/translator/transformations/InterferenceGraphColorer.as \
   com/adobe/AGALOptimiser/translator/transformations/InterferenceGraphEdge.as \
   com/adobe/AGALOptimiser/translator/transformations/InterferenceGraphGenerator.as \
   com/adobe/AGALOptimiser/translator/transformations/InterferenceGraphNode.as \
   com/adobe/AGALOptimiser/translator/transformations/MoveChainReducer.as \
   com/adobe/AGALOptimiser/translator/transformations/PatternPeepholeOptimizer.as \
   com/adobe/AGALOptimiser/translator/transformations/RegisterAssigner.as \
   com/adobe/AGALOptimiser/translator/transformations/SourceRegisterTemplate.as \
   com/adobe/AGALOptimiser/translator/transformations/StandardPeepholeOptimizer.as \
   com/adobe/AGALOptimiser/translator/transformations/TemplateBindings.as \
   com/adobe/AGALOptimiser/translator/transformations/TransformationManager.as \
   com/adobe/AGALOptimiser/translator/transformations/TransformationIterationManager.as \
   com/adobe/AGALOptimiser/translator/transformations/TransformationPattern.as \
   com/adobe/AGALOptimiser/translator/transformations/TransformationSequenceManager.as \
   com/adobe/AGALOptimiser/translator/transformations/TransformationSingletonManager.as \
   com/adobe/AGALOptimiser/translator/transformations/Utils.as \
   com/adobe/AGALOptimiser/type/Type.as \
   com/adobe/AGALOptimiser/type/ArrayType.as \
   com/adobe/AGALOptimiser/type/Constants.as \
   com/adobe/AGALOptimiser/type/ImageType.as \
   com/adobe/AGALOptimiser/type/MatrixType.as \
   com/adobe/AGALOptimiser/type/ScalarType.as \
   com/adobe/AGALOptimiser/type/StringType.as \
   com/adobe/AGALOptimiser/type/TypeSet.as \
   com/adobe/AGALOptimiser/type/TypeUtils.as \
   com/adobe/AGALOptimiser/type/VectorType.as \
   com/adobe/AGALOptimiser/type/VoidType.as \
   com/adobe/AGALOptimiser/utils/SerializationFlags.as \
   com/adobe/AGALOptimiser/utils/SerializationUtils.as \
   com/adobe/AGALOptimiser/utils/Tokenizer.as \
   com/adobe/AGALOptimiser/utils/UniqueNameGenerator.as \
   com/adobe/AGALOptimiser/VariableInfo.as \
   com/adobe/AGALOptimiser/VertexRegisterInfo.as \
com/adobe/AGALOptimiser/agal/AgalParser.as \