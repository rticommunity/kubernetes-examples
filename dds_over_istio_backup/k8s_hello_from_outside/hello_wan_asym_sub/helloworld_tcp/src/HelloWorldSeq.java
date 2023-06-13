
/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from .idl 
using RTI Code Generator (rtiddsgen) version 4.0.0.
The rtiddsgen tool is part of the RTI Connext DDS distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the Code Generator User's Manual.
*/

import java.util.Collection;

import com.rti.dds.infrastructure.Copyable;
import com.rti.dds.util.Enum;
import com.rti.dds.util.Sequence;
import com.rti.dds.util.LoanableSequence;

/**
* A sequence of HelloWorld instances.
*/
public final class HelloWorldSeq extends LoanableSequence implements Copyable {
    // -----------------------------------------------------------------------
    // Package Fields
    // -----------------------------------------------------------------------

    /**
    * When a memory loan has been taken out in the lower layers of 
    * RTI Data Distribution Service, store a pointer to the native sequence here. 
    * That way, when we call finish(), we can give the memory back.
    */
    /*package*/ transient Sequence _loanedInfoSequence = null;

    // -----------------------------------------------------------------------
    // Public Fields
    // -----------------------------------------------------------------------

    // --- Constructors: -----------------------------------------------------

    public HelloWorldSeq() {
        super(HelloWorld.class);
    }

    public HelloWorldSeq (int initialMaximum) {
        super(HelloWorld.class, initialMaximum);
    }

    public HelloWorldSeq (Collection<?> elements) {
        super(HelloWorld.class, elements);
    }

    public  HelloWorld get(int index) { 
        return (HelloWorld) super.get(index); 
    }

    // --- From Copyable: ----------------------------------------------------

    /**
    * Copy data into <code>this</code> object from another.
    * The result of this method is that both <code>this</code>
    * and <code>src</code> will be the same size and contain the
    * same data.
    * 
    * @param src The Object which contains the data to be copied
    * @return <code>this</code>
    * @exception NullPointerException If <code>src</code> is null.
    * @exception ClassCastException If <code>src</code> is not a 
    * <code>Sequence</code> OR if one of the objects contained in
    * the <code>Sequence</code> is not of the expected type.
    * @see com.rti.dds.infrastructure.Copyable#copy_from(java.lang.Object)
    */
    @Override
    public java.lang.Object copy_from(java.lang.Object src) {
        Sequence typedSrc = (Sequence) src;
        final int srcSize = typedSrc.size();
        final int origSize = size();

        // if this object's size is less than the source, ensure we have
        // enough room to store all of the objects
        if (getMaximum() < srcSize) {
            setMaximum(srcSize);
        }

        // trying to avoid clear() method here since it allocates memory
        // (an Iterator)
        // if the source object has fewer items than the current object,
        // remove from the end until the sizes are equal
        if (srcSize < origSize){
            removeRange(srcSize, origSize);
        }

        // copy the data from source into this (into positions that already
        // existed)
        for(int i = 0; (i < origSize) && (i < srcSize); i++){
            if (typedSrc.get(i) == null){
                set(i, null);
            } else {
                // check to see if our entry is null, if it is, a new instance has to be allocated
                if (get(i) == null){ 

                    set(i, HelloWorld.create());
                }
                set(i, ((Copyable) get(i)).copy_from(typedSrc.get(i)));
            }
        }

        // copy 'new' HelloWorld objects (beyond the original size of this object)
        for(int i = origSize; i < srcSize; i++){
            if (typedSrc.get(i) == null) {
                add(null);
            } else {
                // NOTE: we need to create a new object here to hold the copy
                add(HelloWorld.create());
                // we need to do a set here since enums aren't truely Copyable
                set(i, ((Copyable) get(i)).copy_from(typedSrc.get(i)));
            }
        }

        return this;
    }

}

